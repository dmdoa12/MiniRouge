extends Control

const COLOR_EMPTY := Color(0.15, 0.15, 0.15)   # 빈 슬롯 배경
const COLOR_READY := Color(0.25, 0.3, 0.45)    # 스킬 있고 사용 가능
const COLOR_OVERLAY := Color(0, 0, 0, 0.6)     # 쿨타임 부채꼴(반투명 검정)
const ARC_STEPS := 32                          # 부채꼴 부드러움(점 개수)

@onready var key_label: Label = $KeyLabel
@onready var name_label: Label = $NameLabel
@onready var cd_label: Label = $CDLabel

var cooldown_ratio: float = 0.0   # 남은 쿨타임 비율 (1.0=방금 씀, 0.0=준비됨)
var is_empty: bool = true

func _ready() -> void:
	clip_contents = true

func set_slot(key: String, skill) -> void:
	key_label.text = key.to_upper()
	if skill == null:
		is_empty = true
		name_label.text = "비어있음"
		cd_label.text = ""
		cooldown_ratio = 0.0
	else:
		is_empty = false
		name_label.text = skill.skill_name
		if skill.cooldown > 0.0 and skill.current_cooldown > 0.0:
			cooldown_ratio = skill.current_cooldown / skill.cooldown
			cd_label.text = "%.1f" % skill.current_cooldown
		else:
			cooldown_ratio = 0.0
			cd_label.text = ""
	queue_redraw()

func _draw() -> void:
	# 1) 박스 배경
	var bg_color := COLOR_EMPTY if is_empty else COLOR_READY
	draw_rect(Rect2(Vector2.ZERO, size), bg_color)

	# 2) 쿨타임 중이 아니면 끝
	if cooldown_ratio <= 0.0:
		return

	# 3) 시계방향 부채꼴 (12시에서 시작)
	var center := size / 2.0
	var radius := size.length()          # 대각선보다 큼 → clip으로 네모로 잘림
	var start_angle := -PI / 2.0         # 12시 방향
	var sweep := cooldown_ratio * TAU    # 남은 비율만큼 회전(TAU=360도)

	var points := PackedVector2Array()
	points.append(center)
	for i in ARC_STEPS + 1:
		var a := start_angle - sweep * (float(i) / ARC_STEPS)
		points.append(center + Vector2(cos(a), sin(a)) * radius)
	draw_colored_polygon(points, COLOR_OVERLAY)
