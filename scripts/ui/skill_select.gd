extends CanvasLayer

signal skill_chosen(skill_id: String)

var current_skills := []

func _ready() -> void:
	hide()
	$Background/CardContainer/Card1.pressed.connect(func(): _on_card_pressed(0))
	$Background/CardContainer/Card2.pressed.connect(func(): _on_card_pressed(1))
	$Background/CardContainer/Card3.pressed.connect(func(): _on_card_pressed(2))

func show_cards() -> void:
	current_skills = SkillDatabase.get_random_skills(3)
	
	var cards := [
		$Background/CardContainer/Card1,
		$Background/CardContainer/Card2,
		$Background/CardContainer/Card3,
	]
	for i in range(3):
		cards[i].text = current_skills[i]["name"]
	
	show()
	get_tree().paused = true
	
func _on_card_pressed(index: int) -> void:
	var skill_id: String = current_skills[index]["id"]
	emit_signal("skill_chosen", skill_id)
	hide()
	get_tree().paused = false
