extends Node2D

# Registers all platform/ground nodes as "wall" so bullets can detect them.
# Also owns the HUD label updates.

@onready var _hud_health: Label = $HUD/HealthLabel

func _ready() -> void:
	for body in $Platforms.get_children():
		body.add_to_group("wall")

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		_hud_health.text = "HP: " + str(player.health)
	else:
		_hud_health.text = "GAME OVER"
