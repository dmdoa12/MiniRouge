extends Node2D

var direction := Vector2.RIGHT
var arc_range := PI / 3.0
var current_angle := 0.0

func init(spawn_pos: Vector2, attack_dir: Vector2, angle_range: float = PI / 3.0) -> void:
	global_position = spawn_pos
	direction = attack_dir if attack_dir != Vector2.ZERO else Vector2.RIGHT
	arc_range = angle_range
	
	var base_angle := direction.angle()
	current_angle = base_angle - arc_range
	
	var tween := create_tween()
	tween.tween_property(self, "current_angle", base_angle + arc_range, 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)

func _process(_delta: float) -> void:
	queue_redraw()

func _set_angle(val: float) -> void:
	current_angle = val
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, 36.0, current_angle - arc_range * 0.5, current_angle + arc_range * 0.5, 16, Color(1, 1, 0.5, 0.8), 6.0)
