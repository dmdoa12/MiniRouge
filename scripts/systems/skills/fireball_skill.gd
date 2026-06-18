extends SkillBase
class_name FireballSkill

func _init() -> void:
	super("fireball", "화염구", 2.0)

func execute(player: Node) -> void:
	var projectile: Node = player.projectile_scene.instantiate()
	player.get_tree().current_scene.add_child(projectile)
	projectile.init(player.position, player.facing, player.stats.attack * 3, player)
