extends SkillBase
class_name DashSkill

func _init() -> void:
	super("dash", "대시", 1.0, [Tags.MOVEMENT])

func execute(player: Node) -> void:
	var motion: Vector2 = player.facing * 60.0
	var collision: KinematicCollision2D = player.move_and_collide(motion, true)  # true = 검사만
	var target: Vector2
	if collision:
		target = player.position + collision.get_travel()  # 벽 직전까지만
	else:
		target = player.position + motion
	var tween := player.create_tween()
	tween.tween_property(player, "position", target, 0.15)
