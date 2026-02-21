extends Node
# GameState - Global singleton for managing player data and game state

# Player information
var player_username: String = ""

# Ship configuration from ship yard
var ship_config = {
	"ship_class": 1,  # Default to Cruiser
	"main_gun_type": 0,
	"secondary_gun_type": 0,
	"engine_type": 0,
	"fire_control_type": 0,
	"crew_assigned": false
}


# Save ship configuration
func set_ship_config(config: Dictionary):
	ship_config = config.duplicate(true)  # Deep copy to prevent mutations
	print("GameState: Ship config saved - %s" % ship_config)


# Get ship configuration
func get_ship_config() -> Dictionary:
	return ship_config.duplicate(true)  # Deep copy to prevent external mutations


# Set player username
func set_player_username(username: String):
	player_username = username
	print("GameState: Player username set to %s" % username)


# Get player username
func get_player_username() -> String:
	return player_username
