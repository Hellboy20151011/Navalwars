extends Area2D
# Projectile - Naval artillery shell
# Handles ballistics, damage, and collision detection

@export var damage: int = 25
@export var speed: float = 500.0
@export var piercing: bool = false

var velocity: Vector2 = Vector2.ZERO
var travel_distance: float = 0.0
var max_range: float = 2000.0
var trail_node: Line2D = null

const IMPACT_MARKER_FADE_DURATION: float = 3.0

func _ready():
	# Set collision layers
	collision_layer = 4  # Projectile layer
	collision_mask = 3   # Can hit ships (player and enemy)
	
	# Cache trail node reference
	trail_node = $Trail

func initialize(start_position: Vector2, direction: float, projectile_speed: float, projectile_damage: int, hit_mask: int = 3):
	position = start_position
	rotation = direction
	speed = projectile_speed
	damage = projectile_damage
	velocity = Vector2(0, -speed).rotated(direction)
	collision_mask = hit_mask

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
	if not trail_node:
		return
		
	# Add point to trail
	var local_pos = to_local(position - velocity.normalized() * 10)
	if trail_node.get_point_count() < 10:
		trail_node.add_point(local_pos)
	else:
		# Remove oldest point and add new one
		trail_node.remove_point(0)
		trail_node.add_point(local_pos)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		print("Projectile hit! Dealt %d damage" % damage)
	_explode()

func _on_life_timer_timeout():
	_explode()

func _explode():
	# Create small explosion effect on impact/timeout
	var explosion_scene = preload("res://scenes/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.explosion_radius = 25.0
	explosion.explosion_duration = 0.5
	
	# Create impact marker: small green circle that fades out
	var marker = Node2D.new()
	get_parent().add_child(marker)
	marker.global_position = global_position
	marker.z_index = 6
	marker.draw.connect(func():
		marker.draw_circle(Vector2.ZERO, 8.0, Color(0.0, 0.9, 0.2, 0.85))
		marker.draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 32, Color(0.0, 1.0, 0.0, 1.0), 2.0)
	)
	marker.queue_redraw()
	var tween = marker.create_tween()
	tween.tween_property(marker, "modulate", Color(1, 1, 1, 0), IMPACT_MARKER_FADE_DURATION)
	tween.tween_callback(marker.queue_free)
	
	queue_free()
