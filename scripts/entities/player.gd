extends CharacterBody2D

const SPEED = 100.0

var stats: StatSystem
var level_system: LevelSystem
var attack_cooldown := 0.0
var attack_rate = 1.0
var facing := Vector2.RIGHT
var is_invincible := false

var damage_number_scene = preload("res://scenes/ui/damage_number.tscn")
var slash_effect_scene = preload("res://scenes/ui/slash_effect.tscn")
var death_effect_scene = preload("res://scenes/ui/death_effect.tscn")
var projectile_scene = preload("res://scenes/entities/projectile.tscn")

var skill_slots := {
	"q": null,
	"w": null,
	"e": null,
	"r": null
}

signal enemy_killed(enemy: Node)



func _ready() -> void:
	match GameState.selected_class:
		"dealer":
			stats = StatSystem.new(20, 8, 1)
		"tanker":
			stats = StatSystem.new(50, 3, 4)
		"healer":
			stats = StatSystem.new(30, 5, 2)
			
	level_system = LevelSystem.new()
	level_system.leveled_up.connect(_on_level_up)

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
		match GameState.selected_class:
			"dealer":
				_melee_attack(PI / 3.0, 40.0)
			"tanker":
				_melee_attack(PI / 6.0, 25.0)
			"healer":
				_ranged_attack()
		
		
		
	if stats.is_dead():
		get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
		
	if direction != Vector2.ZERO:
		facing = direction.normalized()
		
	for key in skill_slots:
		var skill = skill_slots[key]
		if skill:
			skill.update(delta)
	
	if Input.is_action_just_pressed("skill_q"):
		_use_skill("q")
	if Input.is_action_just_pressed("skill_w"):
		_use_skill("w")
	if Input.is_action_just_pressed("skill_e"):
		_use_skill("e")
	if Input.is_action_just_pressed("skill_r"):
		_use_skill("r")

func _use_skill(slot: String) -> void:
	var skill = skill_slots[slot]
	if skill == null:
		return
	if not skill.is_ready():
		return
		
	skill.trigger()
	skill.execute(self)

func _on_level_up(new_level: int) -> void:
	stats.max_hp += 5
	stats.hp += 5
	stats.attack += 1
	
func _melee_attack(angle_range: float, attack_range: float) -> void:
	attack_cooldown = attack_rate
	
	var effect := slash_effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.init(position, facing, angle_range)
	
	var attack_dir := facing
	
	var bodies := get_tree().get_nodes_in_group("enemies")
	
	for enemy in bodies:
		var distance := position.distance_to(enemy.position)
		var to_enemy: Vector2 = (enemy.position - position).normalized()
		var angle_diff := attack_dir.angle_to(to_enemy)
		
		if distance < attack_range and abs(angle_diff) < angle_range:
			attack_enemy(enemy)
			
func _ranged_attack() -> void:
	attack_cooldown = attack_rate
	
	var projectile := projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.init(position, facing, stats.attack, self)

func attack_enemy(enemy: Node) -> void:
	var damage := stats.attack
	var actual_damage: int = enemy.stats.take_damage(damage)
	
	var dmg_number := damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dmg_number)
	dmg_number.init(actual_damage, enemy.position)
	
	var knockback_dir: Vector2 = (enemy.position - position).normalized()
	enemy.knockback(knockback_dir)
	
	if enemy.stats.is_dead():
		kill_enemy(enemy)
	
func kill_enemy(enemy: Node) -> void:
	var effect := death_effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.init(enemy.position)
	level_system.add_xp(enemy.xp_reward)
	emit_signal("enemy_killed", enemy)
	enemy.queue_free()
	
func add_skill(skill_id: String) -> bool:
	if skill_id in owned_skill_ids():
		return false
	for key in skill_slots:
		if skill_slots[key] == null:
			skill_slots[key] = SkillDatabase.create_skill(skill_id)
			print(key, " 슬롯에 ", skill_id, " 장착됨")
			return true
	return false
	
func activate_shield(duration: float) -> void:
	is_invincible = true
	modulate = Color(0.5, 0.8, 1.0)
	await get_tree().create_timer(duration).timeout
	is_invincible = false
	modulate = Color.WHITE
	
func owned_skill_ids() -> Array:
	var ids := []
	for key in skill_slots:
		var skill = skill_slots[key]
		if skill:
			ids.append(skill.id)
	return ids


	
