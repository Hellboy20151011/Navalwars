extends CharacterBody2D
# Ship Controller - Naval vessel with Navyfield 1 inspired mechanics
# Features: Speed control, turning, main guns, secondary guns, ship classes

signal ship_destroyed

const TURRET_ROTATION_SPEED: float = 2.0  # radians per second
# Ballistic physics constants
const GRAVITY: float = 300.0       # Game pseudo-gravity used in range formula (px/s²)
const MIN_ELEVATION_DEG: float = 5.0   # Minimum gun elevation angle
const MAX_ELEVATION_DEG: float = 70.0  # Maximum gun elevation angle
const ELEVATION_STEP_DEG: float = 1.0  # Elevation change per scroll tick
const PROJECTILE_SCENE = preload("res://scenes/projectile.tscn")
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const MIN_DAMAGE_MULTIPLIER: float = 0.2  # Minimum fraction of damage after armor absorption
const ARMOR_SCALE: float = 100.0          # Divisor that converts armor rating to damage multiplier

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
var armor: int = 0  # Armor rating from ship class data
var class_data: ShipClasses.ShipClassData = null  # ShipClassData instance for ballistic parameters
var gun_elevation_deg: float = 30.0  # Gun elevation angle (Richthöhe) in degrees; scroll wheel adjusts this

# Gun targeting
var target_position: Vector2 = Vector2.ZERO
var has_target: bool = false
var aim_line_node: Node2D = null
var current_turret_local_rotation: float = 0.0

@onready var main_gun_timer: Timer = $MainGunTimer
@onready var secondary_gun_timer: Timer = $SecondaryGunTimer
@onready var turret_front: Node2D = $TurretFront
@onready var turret_rear: Node2D = $TurretRear


# Public getter methods for game manager
func get_health() -> int:
	return health


func get_max_health() -> int:
	return max_health


func get_ship_class_name() -> String:
	return ship_class_name


func get_can_fire_main_guns() -> bool:
	return can_fire_main_guns


func get_gun_elevation_deg() -> float:
	return gun_elevation_deg


func get_target_distance() -> float:
	## Distance from ship to current target position (0 if no target is set)
	if not has_target:
		return 0.0
	return global_position.distance_to(target_position)


func get_ballistic_range() -> float:
	## Current ballistic range at the set gun elevation and ship class muzzle speed
	var gun_speed: float = class_data.main_gun_speed if class_data else 600.0
	return _compute_ballistic_range(gun_speed)


func get_main_gun_dispersion() -> float:
	## Half-angle dispersion (radians) for the main guns
	return class_data.main_gun_dispersion if class_data else 0.017


func get_main_gun_speed() -> float:
	## Muzzle velocity for the main guns
	return class_data.main_gun_speed if class_data else 600.0


# Ballistic range formula: Range = v₀² × sin(2θ) / g
# Gives the horizontal range a shell will travel at the current elevation with the given muzzle speed.
func _compute_ballistic_range(muzzle_speed: float) -> float:
	var theta := deg_to_rad(gun_elevation_deg)
	return muzzle_speed * muzzle_speed * sin(2.0 * theta) / GRAVITY


# Arc height derived from elevation: h_max = v₀² × sin²(θ) / (2g)
# Scaled down by 0.5 to keep the visual in reasonable screen-space pixels.
func _compute_arc_height(muzzle_speed: float) -> float:
	var theta := deg_to_rad(gun_elevation_deg)
	var sin_theta := sin(theta)
	return muzzle_speed * muzzle_speed * sin_theta * sin_theta / (2.0 * GRAVITY) * 0.5


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
	# Line length reflects the current ballistic range based on gun elevation.
	aim_line_node = Node2D.new()
	aim_line_node.z_index = 5
	add_child(aim_line_node)
	aim_line_node.draw.connect(
		func():
			var turret_dir = Vector2(0, -1).rotated(current_turret_local_rotation)
			var muzzle_speed: float = class_data.main_gun_speed if class_data else 600.0
			var computed_range := _compute_ballistic_range(muzzle_speed)
			var endpoint := turret_dir * computed_range
			aim_line_node.draw_dashed_line(
				Vector2.ZERO, endpoint, Color(1.0, 1.0, 0.0, 0.8), 2.0, 20.0
			)
			# Landing-point marker: red circle at the predicted impact spot
			aim_line_node.draw_circle(endpoint, 6.0, Color(1.0, 0.2, 0.2, 0.85))
	)


func _apply_ship_class_stats():
	# Get ship class data and apply to this ship
	class_data = ShipClasses.get_ship_class_data(ship_class)

	ship_class_name = class_data.ship_name
	max_health = class_data.max_health
	max_speed = class_data.max_speed
	acceleration = class_data.acceleration
	turn_speed = class_data.turn_speed
	main_gun_damage = class_data.main_gun_damage
	secondary_gun_damage = class_data.secondary_gun_damage
	armor = class_data.armor

	# Apply visual scale
	var ship_scale = ShipClasses.get_ship_scale(ship_class)
	scale = ship_scale

	print("Ship class applied: %s" % ship_class_name)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				target_position = get_global_mouse_position()
				has_target = true
			MOUSE_BUTTON_WHEEL_UP:
				# Scroll up → increase elevation; range peaks at 45° then decreases above it
				gun_elevation_deg = clamp(gun_elevation_deg + ELEVATION_STEP_DEG, MIN_ELEVATION_DEG, MAX_ELEVATION_DEG)
			MOUSE_BUTTON_WHEEL_DOWN:
				# Scroll down → decrease elevation (flatter arc, shorter range)
				gun_elevation_deg = clamp(gun_elevation_deg - ELEVATION_STEP_DEG, MIN_ELEVATION_DEG, MAX_ELEVATION_DEG)


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

	# Get ballistic parameters from ship class data
	var gun_speed := class_data.main_gun_speed if class_data else 600.0
	var gun_drag := class_data.main_gun_drag if class_data else 0.0
	# Dispersion increases slightly when the ship is moving fast
	var base_disp := class_data.main_gun_dispersion if class_data else 0.017
	var speed_factor: float = abs(current_speed) / max_speed if max_speed > 0.0 else 0.0
	var disp: float = base_disp * (1.0 + 0.5 * speed_factor)
	# Compute range and arc height from current gun elevation (Richthöhe) and muzzle velocity
	var gun_range := _compute_ballistic_range(gun_speed)
	var gun_arc := _compute_arc_height(gun_speed)

	print("Elevation: %.1f° → Range: %.0f px, Arc: %.0f px" % [gun_elevation_deg, gun_range, gun_arc]) if OS.is_debug_build() else null

	# Create main gun projectiles (front and rear turrets)
	_spawn_projectile(Vector2(0, -30), fire_angle, main_gun_damage, gun_speed, gun_drag, disp, gun_arc, gun_range)
	_spawn_projectile(Vector2(0, 30), fire_angle, main_gun_damage, gun_speed, gun_drag, disp, gun_arc, gun_range)


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

	# Get ballistic parameters for secondary guns
	var gun_speed := class_data.secondary_gun_speed if class_data else 700.0
	var gun_drag := class_data.secondary_gun_drag if class_data else 0.0
	var disp := class_data.secondary_gun_dispersion if class_data else 0.035
	# Secondary guns also use current elevation; their faster muzzle speed gives different range
	var gun_range := _compute_ballistic_range(gun_speed)
	var gun_arc := _compute_arc_height(gun_speed)

	# Create secondary gun projectiles (faster, less damage)
	_spawn_projectile(Vector2(-15, -10), rotation, secondary_gun_damage, gun_speed, gun_drag, disp, gun_arc, gun_range)
	_spawn_projectile(Vector2(15, -10), rotation, secondary_gun_damage, gun_speed, gun_drag, disp, gun_arc, gun_range)


func _on_main_gun_timer_timeout():
	can_fire_main_guns = true


func _on_secondary_gun_timer_timeout():
	can_fire_secondary_guns = true


func take_damage(amount: int):
	# Armor reduces incoming damage; heavier armor deflects more
	var reduced: int = max(1, int(float(amount) * max(MIN_DAMAGE_MULTIPLIER, 1.0 - float(armor) / ARMOR_SCALE)))
	health -= reduced
	print("Ship took %d damage (%d after armor %d).\nHealth: %d/%d" % [amount, reduced, armor, health, max_health])

	if health <= 0:
		_destroy_ship()


func _destroy_ship():
	print("Ship destroyed!")

	# Create explosion effect
	var explosion = EXPLOSION_SCENE.instantiate()
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
	flash.draw.connect(
		func():
			var flash_color = Color(1.0, 0.9, 0.5, 0.8)
			flash.draw_circle(Vector2.ZERO, 10, flash_color)
			flash.draw_circle(Vector2.ZERO, 6, Color(1, 1, 1, 0.9))
	)

	flash.queue_redraw()

	# Remove flash after short duration
	await get_tree().create_timer(0.1).timeout
	flash.queue_free()


func _spawn_projectile(offset: Vector2, fire_angle: float, damage: int, speed: float, drag: float = 0.0, dispersion: float = 0.0, arc: float = 60.0, gun_range: float = 0.0):
	var projectile = PROJECTILE_SCENE.instantiate()
	get_parent().add_child(projectile)

	# Calculate spawn position (turret position)
	var spawn_pos = global_position + offset.rotated(rotation)
	# Apply angular dispersion for realistic scatter
	var dispersed_angle := fire_angle + randf_range(-dispersion, dispersion)
	projectile.arc_height = arc
	# Set max_range from the elevation-computed ballistic range so the arc lands at the right spot
	if gun_range > 0.0:
		projectile.max_range = gun_range
	projectile.initialize(spawn_pos, dispersed_angle, speed, damage, 2, drag)  # Only hit enemies (layer 2)
