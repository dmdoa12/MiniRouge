extends Control

func _ready() -> void:
	$HBoxContainer/DealerButton.pressed.connect(_on_dealer_pressed)
	$HBoxContainer/TankerButton.pressed.connect(_on_tanker_pressed)
	$HBoxContainer/HealerButton.pressed.connect(_on_healer_pressed)

func _on_dealer_pressed() -> void:
	GameState.selected_class = "dealer"
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_tanker_pressed() -> void:
	GameState.selected_class = "tanker"
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_healer_pressed() -> void:
	GameState.selected_class = "healer"
	get_tree().change_scene_to_file("res://scenes/game.tscn")
