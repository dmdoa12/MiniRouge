extends CharacterBody2D

const SPEED = 100.0
var stats := StatSystem.new(30, 5, 2)
var attack_cooldown := 0.0
var attack_rate = 1.0
var damage_number_scene = preload("res://scenes/ui/damage_number.tscn")

signal enemy_killed(enemy: Node)

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1	
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1	
		
	velocity = direction.normalized() * SPEED
	move_and_slide()

	if attack_cooldown > 0:
		attack_cooldown -= delta
		
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0:
		_melee_attack()
		
	if stats.is_dead():
		get_tree().quit()

func _melee_attack() -> void:
	attack_cooldown = attack_rate
	
	var bodies := get_tree().get_nodes_in_group("enemies")
	
	for enemy in bodies:
		var distance := position.distance_to(enemy.position)
		if distance < 40.0:
			attack_enemy(enemy)

func attack_enemy(enemy: Node) -> void:
	var damage := stats.attack
	var actual_damage: int = enemy.stats.take_damage(damage)
	
	var dmg_number := damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dmg_number)
	dmg_number.init(actual_damage, enemy.position)
	
	var knockback_dir: Vector2 = (enemy.position - position).normalized()
	enemy.knockback(knockback_dir)
	
	if enemy.stats.is_dead():
		emit_signal("enemy_killed", enemy)
		enemy.queue_free()
