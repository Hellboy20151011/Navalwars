extends Control
# Ship Yard - Main screen for ship configuration
# Resembles a dry dock where players can modify their ship

# Player ship configuration
var player_ship_config = {
	"ship_class": 1,  # 0=Destroyer, 1=Cruiser, 2=Battleship, 3=Carrier
	"main_gun_type": 0,  # Different gun types
	"secondary_gun_type": 0,
	"engine_type": 0,  # Different propulsion systems
	"fire_control_type": 0,  # Fire control systems
	"crew_assigned": false
}

# Ship class names
var ship_class_names = ["Destroyer", "Cruiser", "Battleship", "Carrier"]
var gun_types = ["Standard Guns", "Heavy Guns", "Rapid Fire Guns"]
var engine_types = ["Standard Engine", "High Speed Engine", "Heavy Duty Engine"]
var fire_control_types = ["Basic FCS", "Advanced FCS", "Tactical FCS"]

func _ready():
	print("Ship Yard initialized")
	
	# Connect UI buttons
	_connect_buttons()
	
	# Initialize UI
	_update_ship_display()
	_update_configuration_panel()

func _connect_buttons():
	# Ship class selection
	$UI/ConfigPanel/ShipClassSection/PrevClassButton.connect("pressed", _on_prev_ship_class)
	$UI/ConfigPanel/ShipClassSection/NextClassButton.connect("pressed", _on_next_ship_class)
	
	# Weapons configuration
	$UI/ConfigPanel/WeaponsSection/PrevMainGunButton.connect("pressed", _on_prev_main_gun)
	$UI/ConfigPanel/WeaponsSection/NextMainGunButton.connect("pressed", _on_next_main_gun)
	$UI/ConfigPanel/WeaponsSection/PrevSecGunButton.connect("pressed", _on_prev_sec_gun)
	$UI/ConfigPanel/WeaponsSection/NextSecGunButton.connect("pressed", _on_next_sec_gun)
	
	# Propulsion configuration
	$UI/ConfigPanel/PropulsionSection/PrevEngineButton.connect("pressed", _on_prev_engine)
	$UI/ConfigPanel/PropulsionSection/NextEngineButton.connect("pressed", _on_next_engine)
	
	# Fire control configuration
	$UI/ConfigPanel/FireControlSection/PrevFCSButton.connect("pressed", _on_prev_fcs)
	$UI/ConfigPanel/FireControlSection/NextFCSButton.connect("pressed", _on_next_fcs)
	
	# Crew assignment
	$UI/ConfigPanel/CrewSection/AssignCrewButton.connect("pressed", _on_assign_crew)
	
	# Battle menu button
	$UI/BottomPanel/BattleButton.connect("pressed", _on_battle_button_pressed)

# Ship class navigation
func _on_prev_ship_class():
	player_ship_config["ship_class"] = (player_ship_config["ship_class"] - 1 + 4) % 4
	_update_ship_display()
	_update_configuration_panel()

func _on_next_ship_class():
	player_ship_config["ship_class"] = (player_ship_config["ship_class"] + 1) % 4
	_update_ship_display()
	_update_configuration_panel()

# Weapon configuration
func _on_prev_main_gun():
	var size = gun_types.size()
	player_ship_config["main_gun_type"] = (player_ship_config["main_gun_type"] - 1 + size) % size
	_update_configuration_panel()

func _on_next_main_gun():
	player_ship_config["main_gun_type"] = (player_ship_config["main_gun_type"] + 1) % gun_types.size()
	_update_configuration_panel()

func _on_prev_sec_gun():
	var size = gun_types.size()
	player_ship_config["secondary_gun_type"] = (player_ship_config["secondary_gun_type"] - 1 + size) % size
	_update_configuration_panel()

func _on_next_sec_gun():
	player_ship_config["secondary_gun_type"] = (player_ship_config["secondary_gun_type"] + 1) % gun_types.size()
	_update_configuration_panel()

# Engine configuration
func _on_prev_engine():
	var size = engine_types.size()
	player_ship_config["engine_type"] = (player_ship_config["engine_type"] - 1 + size) % size
	_update_configuration_panel()

func _on_next_engine():
	player_ship_config["engine_type"] = (player_ship_config["engine_type"] + 1) % engine_types.size()
	_update_configuration_panel()

# Fire control configuration
func _on_prev_fcs():
	var size = fire_control_types.size()
	player_ship_config["fire_control_type"] = (player_ship_config["fire_control_type"] - 1 + size) % size
	_update_configuration_panel()

func _on_next_fcs():
	player_ship_config["fire_control_type"] = (player_ship_config["fire_control_type"] + 1) % fire_control_types.size()
	_update_configuration_panel()

# Crew assignment
func _on_assign_crew():
	player_ship_config["crew_assigned"] = !player_ship_config["crew_assigned"]
	_update_configuration_panel()

# Update ship visual display
func _update_ship_display():
	var ship_name = ship_class_names[player_ship_config["ship_class"]]
	$UI/ShipDisplay/ShipNameLabel.text = ship_name
	
	# Update ship visual (simple color-coded representation)
	var ship_visual = $UI/ShipDisplay/ShipVisual
	match player_ship_config["ship_class"]:
		0:  # Destroyer - small, fast
			ship_visual.color = Color(0.3, 0.6, 0.9)
		1:  # Cruiser - medium, balanced
			ship_visual.color = Color(0.5, 0.7, 0.5)
		2:  # Battleship - large, powerful
			ship_visual.color = Color(0.7, 0.3, 0.3)
		3:  # Carrier - support
			ship_visual.color = Color(0.8, 0.7, 0.3)

# Update configuration panel display
func _update_configuration_panel():
	# Ship class
	$UI/ConfigPanel/ShipClassSection/ClassLabel.text = "Ship Class: %s" % ship_class_names[player_ship_config["ship_class"]]
	
	# Weapons
	$UI/ConfigPanel/WeaponsSection/MainGunLabel.text = "Main Guns: %s" % gun_types[player_ship_config["main_gun_type"]]
	$UI/ConfigPanel/WeaponsSection/SecGunLabel.text = "Secondary Guns: %s" % gun_types[player_ship_config["secondary_gun_type"]]
	
	# Propulsion
	$UI/ConfigPanel/PropulsionSection/EngineLabel.text = "Engine: %s" % engine_types[player_ship_config["engine_type"]]
	
	# Fire Control
	$UI/ConfigPanel/FireControlSection/FCSLabel.text = "Fire Control: %s" % fire_control_types[player_ship_config["fire_control_type"]]
	
	# Crew
	var crew_text = "Crew: " + ("ASSIGNED" if player_ship_config["crew_assigned"] else "NOT ASSIGNED")
	$UI/ConfigPanel/CrewSection/CrewStatusLabel.text = crew_text
	$UI/ConfigPanel/CrewSection/AssignCrewButton.text = "Unassign Crew" if player_ship_config["crew_assigned"] else "Assign Crew"

# Navigate to battle menu
func _on_battle_button_pressed():
	# Save configuration to global state
	GameState.set_ship_config(player_ship_config)
	print("Navigating to battle menu with config: %s" % player_ship_config)
	get_tree().change_scene_to_file("res://scenes/battle_menu.tscn")
