extends Node2D
# Game Manager - Main controller for Naval Wars
# Inspired by Navyfield 1 naval combat mechanics

var player_ship: CharacterBody2D
var enemy_ships: Array = []
var game_time: float = 0.0
var score: int = 0

func _ready():
	print("Naval Wars - Starting Game")
	player_ship = get_node_or_null("PlayerShip")
	if player_ship:
		player_ship.connect("ship_destroyed", _on_ship_destroyed)
	
	# Set camera to follow player ship
	var camera = $Camera2D
	if player_ship and camera:
		camera.position = player_ship.position

func _process(delta):
	game_time += delta
	
	# Update camera to follow player ship
	if player_ship:
		var camera = $Camera2D
		camera.position = camera.position.lerp(player_ship.position, delta * 2.0)
		
		# Update UI
		_update_hud()

func _update_hud():
	if player_ship:
		var health_label = $UI/HUD/ShipStatus/HealthLabel
		var speed_label = $UI/HUD/ShipStatus/SpeedLabel
		var ammo_label = $UI/HUD/ShipStatus/AmmoLabel
		
		if health_label:
			health_label.text = "Hull Integrity: %d%%" % player_ship.health
		if speed_label:
			var speed_knots = int(player_ship.velocity.length() / 10.0)
			speed_label.text = "Speed: %d knots" % speed_knots
		if ammo_label:
			if player_ship.can_fire_main_guns:
				ammo_label.text = "Main Guns: Ready"
			else:
				ammo_label.text = "Main Guns: Reloading..."

func _on_ship_destroyed():
	print("Player ship destroyed! Game Over")
	# TODO: Implement game over screen

func spawn_enemy_ship(position: Vector2):
	# TODO: Implement enemy ship spawning
	pass
