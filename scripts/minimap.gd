extends Control
# Minimap - Shows tactical overview of battle arena
# Inspired by NavyField's minimap system

@export var map_size: Vector2 = Vector2(200, 200)
@export var world_size: Vector2 = Vector2(5000, 5000)

var player_ship: Node2D = null
var enemy_ships: Array = []


func _ready():
	custom_minimum_size = map_size
	size = map_size


func _draw():
	# Draw minimap background (ocean)
	draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.1, 0.2, 0.4, 0.8))

	# Draw border
	draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.5, 0.5, 0.8, 1.0), false, 2.0)

	# Draw player ship
	if player_ship and is_instance_valid(player_ship):
		var player_pos = _world_to_minimap(player_ship.global_position)
		draw_circle(player_pos, 5, Color(0.2, 1.0, 0.2, 1.0))  # Green for player

		# Draw player direction indicator
		var direction = Vector2(0, -8).rotated(player_ship.rotation)
		draw_line(player_pos, player_pos + direction, Color(0.2, 1.0, 0.2, 1.0), 2.0)

	# Draw enemy ships
	for enemy in enemy_ships:
		if enemy and is_instance_valid(enemy):
			var enemy_pos = _world_to_minimap(enemy.global_position)
			draw_circle(enemy_pos, 4, Color(1.0, 0.2, 0.2, 1.0))  # Red for enemies


func set_player_ship(ship: Node2D):
	player_ship = ship
	queue_redraw()


func set_enemy_ships(ships: Array):
	enemy_ships = ships
	queue_redraw()


func _world_to_minimap(world_pos: Vector2) -> Vector2:
	# Convert world coordinates to minimap coordinates
	# Center the map on origin (0, 0)
	var normalized_x = (world_pos.x + world_size.x / 2) / world_size.x
	var normalized_y = (world_pos.y + world_size.y / 2) / world_size.y

	return Vector2(normalized_x * map_size.x, normalized_y * map_size.y)
