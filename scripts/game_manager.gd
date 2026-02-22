extends Node2D
# Game Manager - Main controller for Naval Wars
# Inspired by Navyfield 1 naval combat mechanics

# Display constants
const VELOCITY_TO_KNOTS_FACTOR: float = 10.0  # Conversion factor for game units to nautical knots
const ON_TARGET_TOLERANCE_PX: float = 20.0    # Range delta (px) within which a shot is considered "on target"
const DEFAULT_TARGET_SIZE_PX: float = 40.0    # Approximate target cross-section for hit probability (px)

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
		var range_label = $UI/HUD/ShipStatus/RangeLabel
		var bearing_label = $UI/HUD/ShipStatus/BearingLabel
		var hit_prob_label = $UI/HUD/ShipStatus/HitProbLabel
		var fire_corr_label = $UI/HUD/ShipStatus/FireCorrLabel

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

		# ── Artillery calculations (Artillerieberechnungen) ──────────────────
		if player_ship.has_target:
			var target_pos: Vector2 = player_ship.target_position
			var ship_pos: Vector2 = player_ship.global_position
			var target_dist: float = player_ship.get_target_distance()
			var computed_range: float = player_ship.get_ballistic_range()
			var gun_speed: float = player_ship.get_main_gun_speed()

			# Range label: actual distance to target vs computed ballistic range
			if range_label:
				range_label.text = "Entf.: %.0f  Reichw.: %.0f px" % [target_dist, computed_range]

			# Bearing label: Seitenrichtwinkel (bearing from North in Strich)
			if bearing_label:
				var bearing_s: float = ArtilleryCalculator.bearing_strich(ship_pos, target_pos)
				var bearing_d: float = ArtilleryCalculator.bearing_deg(ship_pos, target_pos)
				bearing_label.text = "Peilwinkel: %.0f Strich (%.1f°)" % [bearing_s, bearing_d]

			# Hit probability: Trefferwahrscheinlichkeit
			if hit_prob_label:
				var disp: float = player_ship.get_main_gun_dispersion()
				# Use a target cross-section of ~40 px (typical cruiser width in game units)
				var target_size: float = DEFAULT_TARGET_SIZE_PX
				var prob: float = ArtilleryCalculator.hit_probability(disp, target_dist, target_size)
				hit_prob_label.text = "Trefferw.: %.0f%%" % (prob * 100.0)

			# Fire correction: Feuerkorrektur / Gabelverfahren
			if fire_corr_label:
				var elev_data := ArtilleryCalculator.elevation_for_range(
					target_dist, gun_speed, ArtilleryCalculator.GRAVITY
				)
				if not elev_data["reachable"]:
					fire_corr_label.text = "Feuerkorr.: Außer Reichweite"
				elif abs(computed_range - target_dist) < ON_TARGET_TOLERANCE_PX:
					fire_corr_label.text = "Feuerkorr.: Auf Ziel ✓"
				else:
					var is_over: bool = computed_range > target_dist
					var req_elev: float = elev_data["low_deg"]
					var curr_elev: float = player_ship.get_gun_elevation_deg()
					var delta_elev: float = abs(curr_elev - req_elev)
					if is_over:
						fire_corr_label.text = "Feuerkorr.: Zu weit  ↓ %.1f°" % delta_elev
					else:
						fire_corr_label.text = "Feuerkorr.: Zu kurz  ↑ %.1f°" % delta_elev
		else:
			if range_label:
				range_label.text = "Entf.: ---  Reichw.: %.0f px" % player_ship.get_ballistic_range()
			if bearing_label:
				bearing_label.text = "Peilwinkel: ---"
			if hit_prob_label:
				hit_prob_label.text = "Trefferw.: ---"
			if fire_corr_label:
				fire_corr_label.text = "Feuerkorr.: Kein Ziel"

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
