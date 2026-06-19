extends CanvasLayer

signal skill_chosen(skill_id: String)

var current_skills := []

func _ready() -> void:
	hide()
	$Background/CardContainer/Card1.pressed.connect(func(): _on_card_pressed(0))
	$Background/CardContainer/Card2.pressed.connect(func(): _on_card_pressed(1))
	$Background/CardContainer/Card3.pressed.connect(func(): _on_card_pressed(2))

func show_cards(exclude_ids := []) -> void:
	current_skills = SkillDatabase.get_random_skills(3, exclude_ids)
	if current_skills.is_empty():
		return
	
	var cards := [
		$Background/CardContainer/Card1,
		$Background/CardContainer/Card2,
		$Background/CardContainer/Card3,
	]
	for i in range(cards.size()):
		if i < current_skills.size():
			cards[i].text = current_skills[i]["name"]
			cards[i].show()
		else:
			cards[i].hide()
	
	show()
	get_tree().paused = true
	_animate_in()

func _animate_in() -> void:
	var container: Control = $Background/CardContainer
	var backdrop: ColorRect = $Background/ColorRect
	var home := container.position

	container.position = home + Vector2(500, 0)  # 오른쪽 화면 밖에서 시작
	backdrop.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(container, "position", home, 0.35) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(backdrop, "modulate:a", 1.0, 0.25)
	
func _on_card_pressed(index: int) -> void:
	var skill_id: String = current_skills[index]["id"]
	emit_signal("skill_chosen", skill_id)
	hide()
	get_tree().paused = false
