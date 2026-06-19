extends Area2D

var speed := 200.0
var direction := Vector2.RIGHT
var damage := 5
var source: Node = null

var damage_number_scene = preload("res://scenes/ui/damage_number.tscn")

func init(spawn_pos: Vector2, attack_dir: Vector2, attack_damage: int, attack_source: Node = null) -> void:
	add_to_group("projectiles")
	global_position = spawn_pos
	direction = attack_dir
	damage = attack_damage
	source = attack_source

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	var ray := $RayCast
	ray.target_position = direction * 8
	
	if ray.is_colliding():
		queue_free()
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		var actual_damage: int = body.stats.take_damage(damage)
		
		var dmg_number := damage_number_scene.instantiate()
		get_tree().current_scene.add_child(dmg_number)
		dmg_number.init(actual_damage, body.position)
		body.flash()
		if source:
			source.shake_camera(0.3)
			source.hitstop()
		
		if body.stats.is_dead():
			if source:
				source.kill_enemy(body)
			else:
				body.queue_free()
		queue_free()
