extends Control

@onready var health_bar = $MarginContainer/VBoxContainer/HealthBar
@onready var health_label = $MarginContainer/VBoxContainer/HealthLabel

func _ready():
	# Connect to player ship signals
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.ship_destroyed.connect(_on_ship_destroyed)

func _on_health_changed(health, max_health):
	health_bar.max_value = max_health
	health_bar.value = health
	health_label.text = "Health: %d / %d" % [health, max_health]

func _on_ship_destroyed():
	health_label.text = "DESTROYED"
