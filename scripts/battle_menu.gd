extends Control
# Battle Menu - Select battle mode and start combat


func _ready():
	print("Battle Menu initialized")

	# Connect buttons
	$CenterContainer/VBoxContainer/PracticeBattleButton.connect(
		"pressed", _on_practice_battle_pressed
	)
	$CenterContainer/VBoxContainer/ReturnButton.connect("pressed", _on_return_pressed)

	# Display player's ship configuration
	var config = GameState.get_ship_config()
	var ship_names = ["Destroyer", "Cruiser", "Battleship", "Carrier"]
	$CenterContainer/VBoxContainer/ShipInfoLabel.text = (
		"Your Ship: %s" % ship_names[config["ship_class"]]
	)


func _on_practice_battle_pressed():
	print("Starting practice battle...")
	# Load the main battle scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_return_pressed():
	print("Returning to ship yard...")
	# Return to ship yard
	get_tree().change_scene_to_file("res://scenes/ship_yard.tscn")
