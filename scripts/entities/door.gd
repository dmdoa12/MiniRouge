extends StaticBody2D

var direction: Vector2i
var game_map: Node
var locked := false

func init(dir: Vector2i, map: Node) -> void:
	add_to_group("doors")
	direction = dir
	game_map = map
	print("Door init 호출됨: ", name)
	unlock()

func lock() -> void:
	locked = true
	$ColorRect.color = Color(0.3, 0.15, 0.05)
	set_collision_layer_value(1, true)

func unlock() -> void:
	locked = false
	$ColorRect.color = Color(0.55, 0.27, 0.07)
	set_collision_layer_value(1, false)
