extends Node2D
# Ocean environment - Creates water effect and handles naval environment

var water_color: Color = Color(0.09, 0.22, 0.36, 1)  # Deep blue ocean
var wave_time: float = 0.0

func _ready():
	print("Ocean environment initialized")

func _process(delta):
	wave_time += delta
	# Simple wave animation effect
	# Can be enhanced with shaders for more realistic water

func get_water_resistance() -> float:
	# Ships move slower in water compared to air
	return 0.95
