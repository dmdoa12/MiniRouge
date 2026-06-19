class_name LevelSystem

signal leveled_up(new_level: int)

const BASE_XP = 5
const XP_GROWTH = 5

var level: int = 1
var current_xp: int = 0
var xp_to_next: int

func _init() -> void:
	xp_to_next = _xp_required(level)
	
func _xp_required(lvl: int) -> int:
	return BASE_XP + (lvl - 1) * XP_GROWTH

func add_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= xp_to_next:
		current_xp -= xp_to_next
		level += 1
		xp_to_next = _xp_required(level)
		leveled_up.emit(level)

	
