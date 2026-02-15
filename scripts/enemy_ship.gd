extends CharacterBody2D

# Enemy AI ship
@export var max_speed: float = 150.0
@export var rotation_speed: float = 1.5
@export var max_health: int = 100
@export var fire_rate: float = 1.0
@export var bullet_damage: int = 10
@export var detection_range: float = 400.0
@export var attack_range: float = 300.0

var current_health: int
var can_fire: bool = true
var target: Node2D = null

var bullet_scene = preload("res://scenes/bullet.tscn")

func _ready():
	current_health = max_health

func _physics_process(delta):
	if target:
		ai_behavior(delta)
	else:
		find_target()
	
	move_and_slide()

func find_target():
	# Find player ship
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = position.distance_to(player.position)
		if distance < detection_range:
			target = player

func ai_behavior(delta):
	if not is_instance_valid(target):
		target = null
		return
	
	var distance = position.distance_to(target.position)
	
	# Rotate towards target
	var direction = (target.position - position).normalized()
	var target_rotation = direction.angle() + PI/2
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	
	# Move towards target if too far
	if distance > attack_range:
		velocity = Vector2(0, -max_speed).rotated(rotation)
	elif distance < attack_range * 0.7:
		velocity = Vector2(0, max_speed * 0.5).rotated(rotation)
	else:
		velocity = Vector2.ZERO
	
	# Fire at target if in range
	if distance < attack_range and can_fire:
		fire_weapon()

func fire_weapon():
	can_fire = false
	
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -30).rotated(rotation)
	bullet.rotation = rotation
	bullet.damage = bullet_damage
	bullet.shooter = self
	get_parent().add_child(bullet)
	
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func take_damage(damage: int):
	current_health -= damage
	
	if current_health <= 0:
		die()

func die():
	queue_free()
