extends CharacterBody2D
# Ship Controller - Naval vessel with Navyfield 1 inspired mechanics
# Features: Speed control, turning, main guns, secondary guns, ship classes

signal ship_destroyed

# Ship class system (NavyField-inspired)
@export var ship_class: int = 1  # 0=Destroyer, 1=Cruiser, 2=Battleship, 3=Carrier

# Ship stats (inspired by Navyfield 1) - will be set based on ship_class
@export var max_health: int = 100
@export var max_speed: float = 200.0
@export var acceleration: float = 50.0
@export var turn_speed: float = 1.5
@export var main_gun_damage: int = 50
@export var secondary_gun_damage: int = 15

var health: int = 100
var current_speed: float = 0.0
var rotation_velocity: float = 0.0
var can_fire_main_guns: bool = true
var can_fire_secondary_guns: bool = true
var ship_class_name: String = "Cruiser"

@onready var main_gun_timer: Timer = $MainGunTimer
@onready var secondary_gun_timer: Timer = $SecondaryGunTimer
@onready var turret_front: Node2D = $TurretFront
@onready var turret_rear: Node2D = $TurretRear

# Gun targeting
var target_position: Vector2 = Vector2.ZERO
var has_target: bool = false
var aim_line_node: Node2D = null
var current_turret_local_rotation: float = 0.0

const AIM_LINE_LENGTH: float = 800.0
const TURRET_ROTATION_SPEED: float = 2.0  # radians per second

# Preload projectile scene and ship classes
var projectile_scene = preload("res://scenes/projectile.tscn")
var ship_classes = preload("res://scripts/ship_classes.gd")

# Public getter methods for game manager
func get_health() -> int:
	return health

func get_max_health() -> int:
	return max_health

func get_ship_class_name() -> String:
	return ship_class_name

func get_can_fire_main_guns() -> bool:
	return can_fire_main_guns

func _ready():
	assert(main_gun_timer != null, "MainGunTimer node is missing from ship scene")
	assert(secondary_gun_timer != null, "SecondaryGunTimer node is missing from ship scene")
	assert(turret_front != null, "TurretFront node is missing from ship scene")
	assert(turret_rear != null, "TurretRear node is missing from ship scene")

	# Apply ship class stats
	_apply_ship_class_stats()
	health = max_health
	print("%s initialized with %d health" % [ship_class_name, health])
	
	# Create dashed aim direction indicator (always visible)
	aim_line_node = Node2D.new()
	aim_line_node.z_index = 5
	add_child(aim_line_node)
	aim_line_node.draw.connect(func():
		var turret_dir = Vector2(0, -1).rotated(current_turret_local_rotation)
		aim_line_node.draw_dashed_line(Vector2.ZERO, turret_dir * AIM_LINE_LENGTH, Color(1.0, 1.0, 0.0, 0.8), 2.0, 20.0)
	)

func _apply_ship_class_stats():
	# Get ship class data and apply to this ship
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
	
	print("Ship class applied: %s" % ship_class_name)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		target_position = get_global_mouse_position()
		has_target = true

func _physics_process(delta):
	# Handle movement input
	var forward_input = Input.get_axis("move_backward", "move_forward")
	var turn_input = Input.get_axis("turn_left", "turn_right")
	
	# Adjust speed based on input (gradual acceleration/deceleration)
	if forward_input != 0:
		current_speed = move_toward(current_speed, forward_input * max_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, acceleration * delta * 0.5)
	
	# Apply water resistance
	current_speed *= 0.99
	
	# Handle turning - ships turn slower at lower speeds (realistic naval physics)
	if turn_input != 0 and abs(current_speed) > 10:
		var turn_factor = abs(current_speed) / max_speed  # Turn better at higher speeds
		rotation += turn_input * turn_speed * turn_factor * delta
	
	# Calculate velocity based on rotation and speed
	velocity = Vector2(0, -current_speed).rotated(rotation)
	
	# Move the ship
	move_and_slide()
	
	# Update turret aim every frame (smooth rotation toward target when set)
	_update_turret_aim(delta)
	if aim_line_node:
		aim_line_node.queue_redraw()
	
	# Handle weapons
	if Input.is_action_just_pressed("fire_main_guns"):
		fire_main_guns()
	
	if Input.is_action_pressed("fire_secondary_guns"):
		fire_secondary_guns()

func fire_main_guns():
	if not can_fire_main_guns:
		return
	
	print("Main guns fired!")
	can_fire_main_guns = false
	main_gun_timer.start()
	
	# Create muzzle flash effects
	_create_muzzle_flash(Vector2(0, -30))
	_create_muzzle_flash(Vector2(0, 30))
	
	# Fire in the direction the turrets are currently pointing
	var fire_angle = rotation + current_turret_local_rotation
	
	# Create main gun projectiles (front and rear turrets)
	_spawn_projectile(Vector2(0, -30), fire_angle, main_gun_damage, 600.0)
	_spawn_projectile(Vector2(0, 30), fire_angle, main_gun_damage, 600.0)

func _update_turret_aim(delta: float):
	# Smoothly rotate turrets toward the target when one is set
	if has_target:
		var target_local_rot = _aim_angle_to_target() - rotation
		# Shortest-path angular difference, clamped to [-PI, PI]
		var diff = fposmod(target_local_rot - current_turret_local_rotation + PI, TAU) - PI
		var step = TURRET_ROTATION_SPEED * delta
		current_turret_local_rotation += clamp(diff, -step, step)
	# Always apply current rotation to both turret nodes
	turret_front.rotation = current_turret_local_rotation
	turret_rear.rotation = current_turret_local_rotation

func _aim_angle_to_target() -> float:
	# Returns the fire angle (radians) so Vector2(0,-1).rotated(angle) points at target_position.
	# Adds PI/2 to convert from Godot's east=0 convention to the projectile's north=0 convention.
	return (target_position - global_position).angle() + PI / 2.0

func fire_secondary_guns():
	if not can_fire_secondary_guns:
		return
	
	print("Secondary guns fired!")
	can_fire_secondary_guns = false
	secondary_gun_timer.start()
	
	# Create muzzle flash effects
	_create_muzzle_flash(Vector2(-15, -10))
	_create_muzzle_flash(Vector2(15, -10))
	
	# Create secondary gun projectiles (faster, less damage)
	_spawn_projectile(Vector2(-15, -10), rotation, secondary_gun_damage, 700.0)
	_spawn_projectile(Vector2(15, -10), rotation, secondary_gun_damage, 700.0)

func _on_main_gun_timer_timeout():
	can_fire_main_guns = true

func _on_secondary_gun_timer_timeout():
	can_fire_secondary_guns = true

func take_damage(amount: int):
	health -= amount
	print("Ship took %d damage.\nHealth: %d/%d" % [amount, health, max_health])
	
	if health <= 0:
		_destroy_ship()

func _destroy_ship():
	print("Ship destroyed!")
	
	# Create explosion effect
	var explosion_scene = preload("res://scenes/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.explosion_radius = 80.0  # Larger explosion for player ship
	
	ship_destroyed.emit()
	queue_free()

func repair(amount: int):
	health = min(health + amount, max_health)
	print("Ship repaired.\nHealth: %d/%d" % [health, max_health])

func _create_muzzle_flash(offset: Vector2):
	# Create visual muzzle flash effect
	var flash = Node2D.new()
	flash.z_index = 10
	add_child(flash)
	flash.position = offset
	
	# Draw the flash
	var flash_drawer = func():
		flash.queue_redraw()
	
	flash.draw.connect(func():
		var flash_color = Color(1.0, 0.9, 0.5, 0.8)
		flash.draw_circle(Vector2.ZERO, 10, flash_color)
		flash.draw_circle(Vector2.ZERO, 6, Color(1, 1, 1, 0.9))
	)
	
	flash.queue_redraw()
	
	# Remove flash after short duration
	await get_tree().create_timer(0.1).timeout
	flash.queue_free()

func _spawn_projectile(offset: Vector2, fire_angle: float, damage: int, speed: float):
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	# Calculate spawn position (turret position)
	var spawn_pos = global_position + offset.rotated(rotation)
	projectile.initialize(spawn_pos, fire_angle, speed, damage, 2)  # Only hit enemies (layer 2)
