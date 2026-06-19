extends Camera2D

const DECAY := 5.0                  # 흔들림이 잦아드는 속도
const MAX_OFFSET := Vector2(8, 6)   # 최대 흔들림 픽셀

var trauma := 0.0

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _process(delta: float) -> void:
	if trauma > 0:
		trauma = max(trauma - DECAY * delta, 0.0)
		var shake := trauma * trauma
		offset = Vector2(
			MAX_OFFSET.x * shake * randf_range(-1.0, 1.0),
			MAX_OFFSET.y * shake * randf_range(-1.0, 1.0)
		)
	else:
		offset = Vector2.ZERO
