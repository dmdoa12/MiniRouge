class_name StatSystem

var max_hp: int
var hp: int
var attack: int
var defense: int

func _init(p_max_hp: int, p_attack: int, p_defense: int) -> void:
	max_hp = p_max_hp
	hp = p_max_hp
	attack = p_attack
	defense = p_defense
	
func take_damage(amount: int) -> int:
	var actual_damage: int = max(1, amount - defense)
	hp -= actual_damage
	return actual_damage
	
func is_dead() -> bool:
	return hp <= 0
