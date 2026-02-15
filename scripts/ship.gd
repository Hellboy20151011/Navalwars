extends CharacterBody2D

# Ship properties
@export var max_speed: float = 200.0
@export var acceleration: float = 50.0
@export var rotation_speed: float = 2.0
@export var max_health: int = 100
@export var fire_rate: float = 0.5
@export var bullet_damage: int = 10

var current_health: int
var can_fire: bool = true
var current_speed: float = 0.0

# Preload bullet scene
var bullet_scene = preload("res://scenes/bullet.tscn")

signal health_changed(new_health, max_health)
signal ship_destroyed

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)

func _physics_process(delta):
	handle_input(delta)
	move_and_slide()

func handle_input(delta):
	# Rotation
	if Input.is_action_pressed("turn_left"):
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("turn_right"):
		rotation += rotation_speed * delta
	
	# Movement
	var input_direction = 0
	if Input.is_action_pressed("move_forward"):
		input_direction = 1
	elif Input.is_action_pressed("move_backward"):
		input_direction = -1
	
	# Accelerate/decelerate
	if input_direction != 0:
		current_speed = move_toward(current_speed, max_speed * input_direction, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, acceleration * delta * 0.5)
	
	velocity = Vector2(0, -current_speed).rotated(rotation)
	
	# Firing
	if Input.is_action_pressed("fire") and can_fire:
		fire_weapon()

func fire_weapon():
	can_fire = false
	
	# Create bullet
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -30).rotated(rotation)
	bullet.rotation = rotation
	bullet.damage = bullet_damage
	get_parent().add_child(bullet)
	
	# Reset fire cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func take_damage(damage: int):
	current_health -= damage
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func die():
	ship_destroyed.emit()
	queue_free()
