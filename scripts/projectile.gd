extends Area2D
# Projectile - Naval artillery shell
# Handles ballistics, damage, and collision detection

const IMPACT_MARKER_FADE_DURATION: float = 3.0
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const SPLASH_DURATION: float = 0.8
const SPLASH_OUTER_RADIUS: float = 30.0
const SPLASH_INNER_RADIUS: float = 18.0
const SPLASH_CENTER_SCALE: float = 0.4
const SPLASH_COLOR_OUTER: Color = Color(0.4, 0.7, 1.0)
const SPLASH_COLOR_INNER: Color = Color(0.8, 0.95, 1.0)
const SPLASH_COLOR_CENTER: Color = Color(0.6, 0.85, 1.0)

@export var damage: int = 25
@export var speed: float = 500.0
@export var piercing: bool = false
@export var drag_coefficient: float = 0.0  # Air resistance: velocity decay per second (1/s)
@export var dispersion_deg: float = 0.0  # Extra angular spread in degrees; ship scripts apply their own dispersion

var velocity: Vector2 = Vector2.ZERO
var travel_distance: float = 0.0
var max_range: float = 2000.0
var initial_speed: float = 0.0  # Muzzle velocity for penetration calculation
var exploded := false

@onready var trail_node: Line2D = $Trail
@onready var life_timer: Timer = $LifeTimer


func _ready():
	assert(trail_node != null, "Trail node is missing from projectile scene")
	assert(life_timer != null, "LifeTimer node is missing from projectile scene")
	# Set collision layers
	collision_layer = 4  # Projectile layer
	collision_mask = 3  # Can hit ships (player and enemy)
	# Ensure signals are connected even if scene wiring was removed
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not life_timer.timeout.is_connected(_on_life_timer_timeout):
		life_timer.timeout.connect(_on_life_timer_timeout)


func initialize(
	start_position: Vector2,
	direction: float,
	projectile_speed: float,
	projectile_damage: int,
	hit_mask: int = 3,
	drag: float = 0.0
):
	position = start_position
	speed = projectile_speed
	damage = projectile_damage
	collision_mask = hit_mask
	drag_coefficient = drag
	initial_speed = projectile_speed
	var dispersion_rad := deg_to_rad(randf_range(-dispersion_deg, dispersion_deg))
	rotation = direction + dispersion_rad
	velocity = Vector2(0, -speed).rotated(rotation)


func _physics_process(delta):
	if exploded:
		return

	# Apply air resistance (drag): velocity decays exponentially over time
	if drag_coefficient > 0.0:
		velocity *= exp(-drag_coefficient * delta)

	# Move projectile
	position += velocity * delta
	travel_distance += velocity.length() * delta

	# Check if projectile exceeded max range → miss, water splash
	if travel_distance > max_range:
		_splash()

	# Update trail effect
	_update_trail()


func _update_trail():
	if not trail_node:
		return

	# Add point to trail (local space: projectile is the parent)
	var local_pos := Vector2.ZERO
	if velocity.length() > 0.001:
		local_pos = -velocity.normalized() * 10.0
	if trail_node.get_point_count() < 10:
		trail_node.add_point(local_pos)
	else:
		# Remove oldest point and add new one
		trail_node.remove_point(0)
		trail_node.add_point(local_pos)


func _on_body_entered(body):
	if exploded:
		return

	if body.has_method("take_damage"):
		# Penetration model: effective damage scales with remaining kinetic energy (KE ∝ v²)
		var effective_damage := damage
		if initial_speed > 0.0:
			var speed_ratio := clamp(velocity.length() / initial_speed, 0.0, 1.0)
			var ke_factor := speed_ratio * speed_ratio  # KE ∝ v²
			effective_damage = clamp(int(float(damage) * ke_factor), 1, damage)
		body.take_damage(effective_damage)
		print("Projectile hit! Dealt %d damage (base: %d)" % [effective_damage, damage])

	if not piercing:
		_explode()


func _on_life_timer_timeout():
	_splash()  # Timed out without hitting a target → water impact


func _splash():
	if exploded:
		return
	exploded = true
	var p := get_parent()
	if p == null:
		queue_free()
		return
	# Water-splash effect: expanding blue/white rings to show a miss landing in the sea
	var splash := Node2D.new()
	p.add_child(splash)
	splash.global_position = global_position
	splash.z_index = 5
	splash.set_meta("time", 0.0)
	splash.draw.connect(func():
		var t: float = splash.get_meta("time") / SPLASH_DURATION
		var alpha := 1.0 - t
		var r1 := t * SPLASH_OUTER_RADIUS
		var r2 := t * SPLASH_INNER_RADIUS
		splash.draw_arc(Vector2.ZERO, r1, 0.0, TAU, 32, Color(SPLASH_COLOR_OUTER, alpha * 0.9), 2.5)
		splash.draw_arc(Vector2.ZERO, r2, 0.0, TAU, 24, Color(SPLASH_COLOR_INNER, alpha * 0.6), 1.5)
		splash.draw_circle(Vector2.ZERO, r2 * SPLASH_CENTER_SCALE, Color(SPLASH_COLOR_CENTER, alpha * 0.4))
	)
	var splash_tween := splash.create_tween()
	splash_tween.tween_method(
		func(t: float) -> void: splash.set_meta("time", t); splash.queue_redraw(),
		0.0, SPLASH_DURATION, SPLASH_DURATION
	)
	splash_tween.tween_callback(splash.queue_free)
	queue_free()


func _explode():
	if exploded:
		return
	exploded = true
	var p := get_parent()
	if p == null:
		queue_free()
		return
	# Create small explosion effect on impact/timeout
	var explosion = EXPLOSION_SCENE.instantiate()
	p.add_child(explosion)
	explosion.global_position = global_position
	explosion.explosion_radius = 25.0
	explosion.explosion_duration = 0.5

	# Create impact marker: small green circle that fades out
	var marker = Node2D.new()
	p.add_child(marker)
	marker.global_position = global_position
	marker.z_index = 6
	marker.draw.connect(
		func():
			marker.draw_circle(Vector2.ZERO, 8.0, Color(0.0, 0.9, 0.2, 0.85))
			marker.draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 32, Color(0.0, 1.0, 0.0, 1.0), 2.0)
	)
	marker.queue_redraw()
	var tween = marker.create_tween()
	tween.tween_property(marker, "modulate", Color(1, 1, 1, 0), IMPACT_MARKER_FADE_DURATION)
	tween.tween_callback(marker.queue_free)

	queue_free()
