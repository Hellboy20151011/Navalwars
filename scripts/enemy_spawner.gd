extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var max_enemies: int = 3

var spawn_timer: float = 0.0

func _ready():
	if not enemy_scene:
		enemy_scene = preload("res://scenes/enemy_ship.tscn")

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		
		# Count current enemies
		var current_enemies = get_tree().get_nodes_in_group("enemies").size()
		
		if current_enemies < max_enemies:
			spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# Random spawn position at the top of the screen
	var spawn_x = randf_range(100, 1180)
	var spawn_y = randf_range(50, 200)
	
	enemy.position = Vector2(spawn_x, spawn_y)
	enemy.add_to_group("enemies")
	
	get_parent().add_child(enemy)
