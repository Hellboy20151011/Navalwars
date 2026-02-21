extends Node2D
# Explosion Effect - Visual feedback for ship destruction and hits
# Inspired by NavyField's explosion effects

@export var explosion_duration: float = 1.0
@export var explosion_radius: float = 50.0
@export var explosion_color: Color = Color(1.0, 0.5, 0.0, 1.0)

var time_alive: float = 0.0


func _ready():
	# Auto-cleanup after duration
	await get_tree().create_timer(explosion_duration).timeout
	queue_free()


func _process(delta):
	time_alive += delta
	queue_redraw()


func _draw():
	# Calculate fade out
	var progress = time_alive / explosion_duration
	var alpha = 1.0 - progress
	var current_radius = explosion_radius * (1.0 + progress * 2.0)

	# Draw multiple explosion circles for effect
	var color1 = Color(explosion_color.r, explosion_color.g, explosion_color.b, alpha * 0.8)
	var color2 = Color(1.0, 0.8, 0.0, alpha * 0.6)
	var color3 = Color(0.8, 0.0, 0.0, alpha * 0.4)

	draw_circle(Vector2.ZERO, current_radius, color1)
	draw_circle(Vector2.ZERO, current_radius * 0.7, color2)
	draw_circle(Vector2.ZERO, current_radius * 0.4, color3)

	# Draw expanding ring
	draw_arc(Vector2.ZERO, current_radius * 1.2, 0, TAU, 32, Color(1, 1, 1, alpha * 0.5), 3.0)
