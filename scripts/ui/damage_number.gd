extends Node2D

@onready var label = $Label

func init(damage: int, pos: Vector2) -> void:
	position = pos
	label.text = str(damage)
	
	var tween := create_tween()
	tween.tween_property(self, "position", pos + Vector2(0, -40), 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)
