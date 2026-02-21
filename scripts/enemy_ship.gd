extends CharacterBody2D
# Enemy Ship AI - Navyfield 1 inspired AI behavior
# Features: Target detection, pursuit, evasion, and combat, ship classes

signal enemy_destroyed

# Ship class system
@export var ship_class: int = 1  # 0=Destroyer, 1=Cruiser, 2=Battleship

# Ship stats
@export var max_health: int = 80
@export var max_speed: float = 150.0
@export var acceleration: float = 40.0
@export var turn_speed: float = 1.2
@export var main_gun_damage: int = 40
@export var secondary_gun_damage: int = 12

var health: int = 80
var current_speed: float = 0.0
var target: Node2D = null
var can_fire_main_guns: bool = true
var can_fire_secondary_guns: bool = true
var ai_state: String = "patrol"  # patrol, engage, evade
var ship_class_name: String = "Cruiser"

# Preload projectile scene and ship classes
var projectile_scene = preload("res://scenes/projectile.tscn")
var ship_classes = preload("res://scripts/ship_classes.gd")

# AI parameters
var patrol_point: Vector2
var engagement_range: float = 800.0
var optimal_range: float = 500.0
const FIRING_ANGLE_TOLERANCE: float = 17.0  # Degrees - represents gun turret rotation limits

func _ready():
	# Apply ship class stats
	_apply_ship_class_stats()
	health = max_health
	patrol_point = global_position + Vector2(randf_range(-500, 500), randf_range(-500, 500))
	print("Enemy %s spawned at position: %s" % [ship_class_name, global_position])

func _apply_ship_class_stats():
	# Get ship class data and apply to this enemy ship
	var class_data = ship_classes.get_ship_class_data(ship_class)
	
	ship_class_name = class_data.ship_name
	max_health = class_data.max_health
	max_speed = class_data.max_speed
	acceleration = class_data.acceleration
	turn_speed = class_data.turn_speed
	main_gun_damage = class_data.main_gun_damage
	secondary_gun_damage = class_data.secondary_gun_damage
	
	# Apply visual scale
	var ship_scale = ship_classes.get_ship_scale(ship_class)
	scale = ship_scale
	
	# Set different color for enemies (darker)
	modulate = Color(0.8, 0.6, 0.6)

func _physics_process(delta):
	match ai_state:
		"patrol":
			_patrol_behavior(delta)
		"engage":
			_engage_behavior(delta)
		"evade":
			_evade_behavior(delta)
	
	# Move the ship
	move_and_slide()

func _patrol_behavior(delta):
	# Move towards patrol point
	var direction_to_patrol = (patrol_point - global_position).normalized()
	var distance_to_patrol = global_position.distance_to(patrol_point)
	
	if distance_to_patrol > 50:
		_move_towards_direction(direction_to_patrol, delta)
	else:
		# Reached patrol point, pick new one
		patrol_point = global_position + Vector2(randf_range(-500, 500), randf_range(-500, 500))

func _engage_behavior(delta):
	if target == null or not is_instance_valid(target):
		ai_state = "patrol"
		return
	
	var direction_to_target = (target.global_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target.global_position)
	
	# Maintain optimal combat range
	if distance_to_target > optimal_range:
		# Move closer
		_move_towards_direction(direction_to_target, delta)
	elif distance_to_target < optimal_range * 0.7:
		# Too close, back away
		_move_towards_direction(-direction_to_target, delta)
	else:
		# At good range, circle target
		var perpendicular = direction_to_target.orthogonal()
		_move_towards_direction(perpendicular, delta)
	
	# Fire weapons if in range
	if distance_to_target < engagement_range:
		_attempt_fire_weapons(direction_to_target)

func _evade_behavior(delta):
	# Low health evasion behavior
	if target == null:
		ai_state = "patrol"
		return
	
	var direction_away = (global_position - target.global_position).normalized()
	_move_towards_direction(direction_away, delta)
	
	# Return to engage if health recovers
	if health > max_health * 0.4:
		ai_state = "engage"

func _move_towards_direction(direction: Vector2, delta: float):
	# Calculate desired rotation
	var desired_rotation = direction.angle() + PI/2
	
	# Smooth rotation towards target
	rotation = lerp_angle(rotation, desired_rotation, turn_speed * delta)
	
	# Accelerate
	current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	current_speed *= 0.99  # Water resistance
	
	# Calculate velocity
	velocity = Vector2(0, -current_speed).rotated(rotation)

func _attempt_fire_weapons(direction_to_target: Vector2):
	# Check if guns are aimed roughly at target
	var gun_direction = Vector2(0, -1).rotated(rotation)
	var aim_angle = gun_direction.angle_to(direction_to_target)
	
	if abs(aim_angle) < deg_to_rad(FIRING_ANGLE_TOLERANCE):
		if can_fire_main_guns and randf() < 0.3:
			fire_main_guns()
		if can_fire_secondary_guns and randf() < 0.5:
			fire_secondary_guns()

func fire_main_guns():
	if not can_fire_main_guns:
		return
	
	can_fire_main_guns = false
	$MainGunTimer.start()
	
	# Spawn projectiles
	_spawn_projectile(Vector2(0, -25), main_gun_damage, 550.0)
	_spawn_projectile(Vector2(0, 25), main_gun_damage, 550.0)

func fire_secondary_guns():
	if not can_fire_secondary_guns:
		return
	
	can_fire_secondary_guns = false
	$SecondaryGunTimer.start()
	
	# Spawn projectiles
	_spawn_projectile(Vector2(-12, -8), secondary_gun_damage, 650.0)
	_spawn_projectile(Vector2(12, -8), secondary_gun_damage, 650.0)

func _spawn_projectile(offset: Vector2, damage: int, speed: float):
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	var spawn_pos = global_position + offset.rotated(rotation)
	projectile.initialize(spawn_pos, rotation, speed, damage)

func _on_main_gun_timer_timeout():
	can_fire_main_guns = true

func _on_secondary_gun_timer_timeout():
	can_fire_secondary_guns = true

func _on_ai_timer_timeout():
	# Periodic AI state evaluation
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		
		if health < max_health * 0.3:
			ai_state = "evade"
		elif distance < engagement_range:
			ai_state = "engage"
		else:
			ai_state = "patrol"

func _on_detection_area_body_entered(body):
	# Detect player ship
	if body.is_in_group("player") or body.name == "PlayerShip":
		target = body
		ai_state = "engage"
		print("Enemy detected player ship!")

func _on_detection_area_body_exited(body):
	if body == target:
		target = null
		ai_state = "patrol"

func take_damage(amount: int):
	health -= amount
	print("Enemy ship took %d damage. Health: %d/%d" % [amount, health, max_health])
	
	if health <= 0:
		_destroy_ship()

func _destroy_ship():
	print("Enemy ship destroyed!")
	
	# Create explosion effect
	var explosion_scene = preload("res://scenes/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.explosion_radius = 60.0
	
	enemy_destroyed.emit()
	queue_free()
