extends Node

var skill_pool := [
	{"id": "dash", "name": "대시", "cooldown": 1.0},
	{"id": "fireball", "name": "화염구", "cooldown": 2.0},
	{"id": "heal", "name": "회복", "cooldown": 5.0},
	{"id": "spin", "name": "회전베기", "cooldown": 3.0},
	{"id": "shield", "name": "보호막", "cooldown": 6.0},
]

func get_random_skills(count: int, exclude_ids: Array = []) -> Array:
	var pool := []
	for entry in skill_pool:
		if entry["id"] not in exclude_ids:
			pool.append(entry)
	pool.shuffle()
	return pool.slice(0, count)

func create_skill(id: String) -> SkillBase:
	match id:
		"dash":
			return DashSkill.new()
		"heal":
			return HealSkill.new()
		"fireball":
			return FireballSkill.new()
		"spin":
			return SpinSkill.new()
		"shield":
			return ShieldSkill.new()
	return null
