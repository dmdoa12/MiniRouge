class_name SkillBase

var id: String
var skill_name: String
var cooldown: float
var current_cooldown: float = 0.0

func _init(skill_id: String, name: String, cd: float) -> void:
	id = skill_id
	skill_name = name
	cooldown = cd
	
func is_ready() -> bool:
	return current_cooldown <= 0.0
	
func trigger() -> void:
	current_cooldown = cooldown
	
func update(delta: float) -> void:
	if current_cooldown > 0:
		current_cooldown -= delta

func execute(player: Node) -> void:
	pass
