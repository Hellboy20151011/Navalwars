extends StaticBody2D
# World Boundary - Defines the battle arena limits
# Inspired by NavyField's map boundaries

@export var boundary_width: float = 5000.0
@export var boundary_height: float = 5000.0

func _ready():
	# Create collision shape for boundary
	var collision_shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	
	# Set up the boundary rectangle (hollow)
	rectangle.size = Vector2(boundary_width, boundary_height)
	collision_shape.shape = rectangle
	
	add_child(collision_shape)
	
	print("World boundary created: %dx%d" % [boundary_width, boundary_height])

func _draw():
	# Draw boundary lines for visual reference
	var half_w = boundary_width / 2
	var half_h = boundary_height / 2
	
	# Draw rectangle border
	draw_rect(Rect2(-half_w, -half_h, boundary_width, boundary_height), Color(0.5, 0.5, 0.8, 0.3), false, 3.0)
