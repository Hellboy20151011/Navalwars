extends CharacterBody2D
# Ship Controller - Naval vessel with Navyfield 1 inspired mechanics
# Features: Speed control, turning, main guns, secondary guns

signal ship_destroyed

# Ship stats (inspired by Navyfield 1)
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

# Preload projectile scene
var projectile_scene = preload("res://scenes/projectile.tscn")

# Public getter methods for game manager
func get_health() -> int:
	return health

func get_can_fire_main_guns() -> bool:
	return can_fire_main_guns

func _ready():
	health = max_health
	print("Ship initialized with %d health" % health)

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
	$MainGunTimer.start()
	
	# Create main gun projectiles (front and rear turrets)
	_spawn_projectile(Vector2(0, -30), main_gun_damage, 600.0)
	_spawn_projectile(Vector2(0, 30), main_gun_damage, 600.0)

func fire_secondary_guns():
	if not can_fire_secondary_guns:
		return
	
	print("Secondary guns fired!")
	can_fire_secondary_guns = false
	$SecondaryGunTimer.start()
	
	# Create secondary gun projectiles (faster, less damage)
	_spawn_projectile(Vector2(-15, -10), secondary_gun_damage, 700.0)
	_spawn_projectile(Vector2(15, -10), secondary_gun_damage, 700.0)

func _on_main_gun_timer_timeout():
	can_fire_main_guns = true

func _on_secondary_gun_timer_timeout():
	can_fire_secondary_guns = true

func take_damage(amount: int):
	health -= amount
	print("Ship took %d damage. Health: %d/%d" % [amount, health, max_health])
	
	if health <= 0:
		_destroy_ship()

func _destroy_ship():
	print("Ship destroyed!")
	ship_destroyed.emit()
	# TODO: Add explosion effect
	queue_free()

func repair(amount: int):
	health = min(health + amount, max_health)
	print("Ship repaired. Health: %d/%d" % [health, max_health])

func _spawn_projectile(offset: Vector2, damage: int, speed: float):
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	# Calculate spawn position (turret position)
	var spawn_pos = global_position + offset.rotated(rotation)
	projectile.initialize(spawn_pos, rotation, speed, damage)
