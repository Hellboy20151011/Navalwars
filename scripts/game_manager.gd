extends Node2D
# Game Manager - Main controller for Naval Wars
# Inspired by Navyfield 1 naval combat mechanics

# Display constants
const VELOCITY_TO_KNOTS_FACTOR: float = 10.0  # Conversion factor for game units to nautical knots

# Preload enemy ship scene
var enemy_ship_scene = preload("res://scenes/enemy_ship.tscn")

var player_ship: CharacterBody2D
var enemy_ships: Array = []
var game_time: float = 0.0
var score: int = 0
var enemy_spawn_timer: float = 0.0
var enemy_spawn_interval: float = 20.0
var camera: Camera2D = null
var minimap: Control = null


func _ready():
	print("Naval Wars - Starting Game")
	player_ship = get_node_or_null("PlayerShip")
	if player_ship:
		# Apply ship configuration from GameState
		var config = GameState.get_ship_config()
		player_ship.ship_class = config["ship_class"]
		print("Applying ship configuration: %s" % config)

		player_ship.connect("ship_destroyed", _on_ship_destroyed)
		# Add player to group for enemy detection
		player_ship.add_to_group("player")

	# Cache camera reference
	camera = $Camera2D
	if player_ship and camera:
		camera.position = player_ship.position

	# Setup minimap
	minimap = get_node_or_null("UI/HUD/Minimap")
	if minimap and player_ship:
		minimap.set_player_ship(player_ship)

	# Connect return button
	var return_button = get_node_or_null("UI/HUD/ReturnButton")
	if return_button:
		return_button.connect("pressed", _on_return_to_menu)

	# Spawn initial enemies
	spawn_enemy_ship(Vector2(1500, 500))
	spawn_enemy_ship(Vector2(-1500, -500))


func _process(delta):
	game_time += delta
	enemy_spawn_timer += delta

	# Spawn new enemies periodically
	if enemy_spawn_timer >= enemy_spawn_interval:
		enemy_spawn_timer = 0.0
		_spawn_random_enemy()

	# Update camera to follow player ship
	if player_ship and camera:
		camera.position = camera.position.lerp(player_ship.position, delta * 2.0)

		# Update UI
		_update_hud()

	# Update minimap with enemy ships
	if minimap:
		minimap.set_enemy_ships(enemy_ships)

	# Clean up destroyed enemy ships from array
	enemy_ships = enemy_ships.filter(func(ship): return is_instance_valid(ship))


func _update_hud():
	if player_ship and is_instance_valid(player_ship):
		var health_label = $UI/HUD/ShipStatus/HealthLabel
		var speed_label = $UI/HUD/ShipStatus/SpeedLabel
		var ammo_label = $UI/HUD/ShipStatus/AmmoLabel
		var class_label = $UI/HUD/ShipStatus/ClassLabel
		var elevation_label = $UI/HUD/ShipStatus/ElevationLabel

		if health_label:
			var health_percent = int(
				(float(player_ship.get_health()) / float(player_ship.get_max_health())) * 100
			)
			health_label.text = "Hull Integrity: %d%%" % health_percent
		if speed_label:
			var speed_knots = int(player_ship.velocity.length() / VELOCITY_TO_KNOTS_FACTOR)
			speed_label.text = "Speed: %d knots" % speed_knots
		if ammo_label:
			if player_ship.get_can_fire_main_guns():
				ammo_label.text = "Main Guns: Ready"
			else:
				ammo_label.text = "Main Guns: Reloading..."
		if class_label:
			class_label.text = "Ship: %s" % player_ship.get_ship_class_name()
		if elevation_label and player_ship.has_method("get_gun_elevation_deg"):
			var elev := player_ship.get_gun_elevation_deg()
			elevation_label.text = "Elevation (Richthöhe): %.0f°  [scroll ↑↓]" % elev

	# Update score
	var score_label = $UI/HUD/ScoreLabel
	if score_label:
		score_label.text = "Score: %d" % score


func _on_ship_destroyed():
	print("Player ship destroyed! Game Over")
	# TODO: Implement game over screen
	get_tree().reload_current_scene()


func spawn_enemy_ship(spawn_position: Vector2, enemy_class: int = -1):
	var enemy = enemy_ship_scene.instantiate()
	add_child(enemy)
	enemy.global_position = spawn_position

	# Set random ship class if not specified
	# Note: Carrier (class 3) excluded from random spawning as it's designed for player use
	# Enemies use Destroyer (0), Cruiser (1), or Battleship (2) for balanced combat
	const NUM_SPAWNABLE_ENEMY_CLASSES = 3
	if enemy_class == -1:
		enemy_class = randi() % NUM_SPAWNABLE_ENEMY_CLASSES
	enemy.ship_class = enemy_class

	enemy.connect("enemy_destroyed", _on_enemy_destroyed)
	enemy_ships.append(enemy)
	print("Enemy ship spawned at: %s" % spawn_position)


func _spawn_random_enemy():
	# Spawn enemy at random position around player
	if not player_ship:
		return

	var spawn_distance = randf_range(1000, 1500)
	var spawn_angle = randf_range(0, TAU)
	var spawn_pos = (
		player_ship.global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance
	)
	spawn_enemy_ship(spawn_pos)


func _on_enemy_destroyed():
	score += 100
	print("Enemy destroyed! Score: %d" % score)


func _on_return_to_menu():
	print("Returning to battle menu...")
	get_tree().change_scene_to_file("res://scenes/battle_menu.tscn")
