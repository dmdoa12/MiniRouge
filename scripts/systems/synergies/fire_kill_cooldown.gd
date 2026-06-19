class_name FireKillCooldown
extends SynergyBase

func _init() -> void:
	id = "fire_kill_cd"
	trigger = "enemy_killed"

func apply(player: Node, _enemy) -> void:
	for key in player.skill_slots:
		var skill = player.skill_slots[key]
		if skill and skill.has_tag(Tags.FIRE):
			skill.current_cooldown = max(0.0, skill.current_cooldown - 1.0)
