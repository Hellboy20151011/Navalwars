extends Control
# Login Screen - Entry point for Naval Wars game

signal login_successful(username: String)

func _ready():
	# Connect button signals
	$CenterContainer/VBoxContainer/LoginButton.connect("pressed", _on_login_button_pressed)
	
	# Set focus to username field
	$CenterContainer/VBoxContainer/UsernameInput.grab_focus()
	
	print("Login screen initialized")

func _on_login_button_pressed():
	var username = $CenterContainer/VBoxContainer/UsernameInput.text
	var password = $CenterContainer/VBoxContainer/PasswordInput.text
	
	# Simple validation (for now, accept any non-empty username)
	if username.strip_edges().length() > 0:
		print("Login successful for user: %s" % username)
		emit_signal("login_successful", username)
		# Transition to ship yard
		get_tree().change_scene_to_file("res://scenes/ship_yard.tscn")
	else:
		print("Login failed: Username required")
		$CenterContainer/VBoxContainer/ErrorLabel.text = "Please enter a username"
		$CenterContainer/VBoxContainer/ErrorLabel.show()

func _input(event):
	# Allow Enter key to login only when username field has focus
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if $CenterContainer/VBoxContainer/UsernameInput.has_focus() or $CenterContainer/VBoxContainer/PasswordInput.has_focus():
			_on_login_button_pressed()
