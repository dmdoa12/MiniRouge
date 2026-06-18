extends SkillBase
class_name HealSkill

func _init() -> void:
	super("heal", "회복", 5.0)

func execute(player: Node) -> void:
	player.stats.hp = min(player.stats.hp + 10, player.stats.max_hp)
