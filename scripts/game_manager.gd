extends Node2D
# Game Manager - Main controller for Naval Wars
# Inspired by Navyfield 1 naval combat mechanics

var player_ship: CharacterBody2D
var enemy_ships: Array = []
var game_time: float = 0.0
var score: int = 0
var enemy_spawn_timer: float = 0.0
var enemy_spawn_interval: float = 20.0

# Preload enemy ship scene
var enemy_ship_scene = preload("res://scenes/enemy_ship.tscn")

func _ready():
	print("Naval Wars - Starting Game")
	player_ship = get_node_or_null("PlayerShip")
	if player_ship:
		player_ship.connect("ship_destroyed", _on_ship_destroyed)
		# Add player to group for enemy detection
		player_ship.add_to_group("player")
	
	# Set camera to follow player ship
	var camera = $Camera2D
	if player_ship and camera:
		camera.position = player_ship.position
	
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
	if player_ship:
		var camera = $Camera2D
		camera.position = camera.position.lerp(player_ship.position, delta * 2.0)
		
		# Update UI
		_update_hud()
	
	# Clean up destroyed enemy ships from array
	enemy_ships = enemy_ships.filter(func(ship): return is_instance_valid(ship))

func _update_hud():
	if player_ship and is_instance_valid(player_ship):
		var health_label = $UI/HUD/ShipStatus/HealthLabel
		var speed_label = $UI/HUD/ShipStatus/SpeedLabel
		var ammo_label = $UI/HUD/ShipStatus/AmmoLabel
		
		if health_label:
			health_label.text = "Hull Integrity: %d%%" % player_ship.get_health()
		if speed_label:
			var speed_knots = int(player_ship.velocity.length() / 10.0)
			speed_label.text = "Speed: %d knots" % speed_knots
		if ammo_label:
			if player_ship.get_can_fire_main_guns():
				ammo_label.text = "Main Guns: Ready"
			else:
				ammo_label.text = "Main Guns: Reloading..."
	
	# Update score
	var score_label = $UI/HUD/ScoreLabel
	if score_label:
		score_label.text = "Score: %d" % score

func _on_ship_destroyed():
	print("Player ship destroyed! Game Over")
	# TODO: Implement game over screen
	get_tree().reload_current_scene()

func spawn_enemy_ship(spawn_position: Vector2):
	var enemy = enemy_ship_scene.instantiate()
	add_child(enemy)
	enemy.global_position = spawn_position
	enemy.connect("enemy_destroyed", _on_enemy_destroyed)
	enemy_ships.append(enemy)
	print("Enemy ship spawned at: %s" % spawn_position)

func _spawn_random_enemy():
	# Spawn enemy at random position around player
	if not player_ship:
		return
	
	var spawn_distance = randf_range(1000, 1500)
	var spawn_angle = randf_range(0, TAU)
	var spawn_pos = player_ship.global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance
	spawn_enemy_ship(spawn_pos)

func _on_enemy_destroyed():
	score += 100
	print("Enemy destroyed! Score: %d" % score)
