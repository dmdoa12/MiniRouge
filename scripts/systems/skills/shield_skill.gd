extends SkillBase
class_name ShieldSkill

func _init() -> void:
	super("shield", "보호막", 6.0, [Tags.DEFENSE])

func execute(player: Node) -> void:
	player.activate_shield(2.0)
