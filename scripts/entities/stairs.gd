extends Area2D

signal player_entered

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	player_entered.emit()
