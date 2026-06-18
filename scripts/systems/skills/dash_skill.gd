extends SkillBase
class_name DashSkill

func _init() -> void:
	super("dash", "대시", 1.0)

func execute(player: Node) -> void:
	var target: Vector2 = player.position + player.facing * 60.0
	var tween := player.create_tween()
	tween.tween_property(player, "position", target, 0.15)
