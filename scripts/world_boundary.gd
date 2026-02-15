extends StaticBody2D
# World Boundary - Defines the battle arena limits
# Inspired by NavyField's map boundaries

@export var boundary_width: float = 5000.0
@export var boundary_height: float = 5000.0

func _ready():
	print("World boundary created: %dx%d" % [boundary_width, boundary_height])
	queue_redraw()

func _draw():
	# Draw boundary lines for visual reference
	var half_w = boundary_width / 2
	var half_h = boundary_height / 2
	
	# Draw rectangle border (NavyField-style blue boundary lines)
	draw_rect(Rect2(-half_w, -half_h, boundary_width, boundary_height), Color(0.5, 0.5, 0.8, 0.5), false, 5.0)
	
	# Draw corner markers
	var marker_size = 100
	_draw_corner_marker(Vector2(-half_w, -half_h), marker_size)
	_draw_corner_marker(Vector2(half_w, -half_h), marker_size)
	_draw_corner_marker(Vector2(-half_w, half_h), marker_size)
	_draw_corner_marker(Vector2(half_w, half_h), marker_size)

func _draw_corner_marker(pos: Vector2, size: float):
	# Draw X-shaped markers at corners
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), Color(0.8, 0.8, 1.0, 0.6), 3.0)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), Color(0.8, 0.8, 1.0, 0.6), 3.0)

