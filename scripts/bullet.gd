extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
@export var lifetime: float = 5.0

var shooter: Node = null

func _ready():
	# Auto-delete after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# Move bullet forward
	position += Vector2(0, -speed).rotated(rotation) * delta

func _on_body_entered(body):
	# Hit a ship (but not the one that fired it)
	if body != shooter and body.has_method("take_damage"):
		body.take_damage(damage)
	if body != shooter:
		queue_free()
