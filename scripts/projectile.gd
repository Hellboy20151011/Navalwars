extends Area2D
# Projectile - Naval artillery shell
# Handles ballistics, damage, and collision detection

@export var damage: int = 25
@export var speed: float = 500.0
@export var piercing: bool = false

var velocity: Vector2 = Vector2.ZERO
var travel_distance: float = 0.0
var max_range: float = 2000.0

func _ready():
	# Set collision layers
	collision_layer = 4  # Projectile layer
	collision_mask = 3   # Can hit ships (player and enemy)

func initialize(start_position: Vector2, direction: float, projectile_speed: float, projectile_damage: int):
	position = start_position
	rotation = direction
	speed = projectile_speed
	damage = projectile_damage
	velocity = Vector2(0, -speed).rotated(direction)

func _physics_process(delta):
	# Move projectile
	position += velocity * delta
	travel_distance += velocity.length() * delta
	
	# Check if projectile exceeded max range
	if travel_distance > max_range:
		_explode()
	
	# Update trail effect
	_update_trail()

func _update_trail():
	var trail = $Trail
	if not trail:
		return
		
	# Add point to trail
	var local_pos = to_local(position - velocity.normalized() * 10)
	if trail.get_point_count() < 10:
		trail.add_point(local_pos)
	else:
		# Remove oldest point and add new one
		trail.remove_point(0)
		trail.add_point(local_pos)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		print("Projectile hit! Dealt %d damage" % damage)
	_explode()

func _on_life_timer_timeout():
	_explode()

func _explode():
	# TODO: Add explosion effect
	queue_free()
