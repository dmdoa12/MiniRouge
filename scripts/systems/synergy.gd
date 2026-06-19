class_name SynergyBase

var id: String
var trigger: String   # 어느 이벤트를 듣나 ("enemy_killed" 등)

func setup(player: Node) -> void:
	match trigger:
		"enemy_killed":
			Events.enemy_killed.connect(func(enemy): apply(player, enemy))

func apply(player: Node, arg) -> void:
	pass   # 효과는 자식이 구현
