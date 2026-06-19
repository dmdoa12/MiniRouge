extends SkillBase
class_name SpinSkill

func _init() -> void:
	super("spin", "회전베기", 3.0, [Tags.AOE, Tags.MELEE])

func execute(player: Node) -> void:
	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		var distance: float = player.position.distance_to(enemy.position)
		if distance < 60.0:
			player.attack_enemy(enemy)
