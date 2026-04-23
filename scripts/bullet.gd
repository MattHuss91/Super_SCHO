extends Area2D

# Player bullet — hits enemies and walls, ignored by player

const SPEED    := 520.0
const LIFETIME := 2.5

var direction  := Vector2.RIGHT
var _life      := LIFETIME

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction * SPEED * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		body.take_damage()
		queue_free()
	elif body.is_in_group("wall"):
		queue_free()
