extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
@export var lifetime: float = 5.0

func _ready():
	# Auto-delete after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# Move bullet forward
	position += Vector2(0, -speed).rotated(rotation) * delta

func _on_body_entered(body):
	# Hit a ship
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
