extends Control

func _ready() -> void:
	Engine.time_scale = 1.0
	$RestartButton.pressed.connect(_on_restart_pressed)
	
func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
