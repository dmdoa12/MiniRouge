extends CPUParticles2D

func init(spawn_pos: Vector2) -> void:
	global_position = spawn_pos
	emitting = true
	await get_tree().create_timer(lifetime + 0.1).timeout
	queue_free()
