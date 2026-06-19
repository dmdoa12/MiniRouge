extends CharacterBody2D

const BASE_HP = 10
const BASE_ATK = 3
const BASE_DEF = 1
const HP_PER_FLOOR = 5
const ATK_PER_FLOOR = 1
const BASE_XP_REWARD = 2
const XP_PER_FLOOR = 1
const SPEED = 50.0

var stats := StatSystem.new(10, 3, 1)
var xp_reward := 2
var attack_cooldown := 0.0
var attack_rate := 1.0
var knockback_velocity := Vector2.ZERO
var player: Node
var flash_tween: Tween

func init_pos(start_pos: Vector2, player_node: Node, floor: int) -> void:
	player = player_node
	position = start_pos
	_apply_floor_scaling(floor)

func _physics_process(delta: float) -> void:
	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)
		if knockback_velocity.length() < 1.0:
			knockback_velocity = Vector2.ZERO
	else:
		var direction: Vector2 = (player.position - position).normalized()
		if position.distance_to(player.position) > 20.0:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
	
	move_and_slide()
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	var distance: float = position.distance_to(player.position as Vector2)
	if distance < 20.0 and attack_cooldown <= 0:
		_attack_player()
		
func _attack_player() -> void:
	attack_cooldown = attack_rate
	if player.is_invincible:
		return
	player.stats.take_damage(stats.attack)
	
func knockback(direction: Vector2) -> void:
	knockback_velocity = direction * 80.0

func flash() -> void:
	if flash_tween:
		flash_tween.kill()
	modulate = Color(5, 5, 5)
	flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color.WHITE, 0.15)

func _apply_floor_scaling(floor: int) -> void:
	var hp := BASE_HP + (floor - 1) * HP_PER_FLOOR
	var atk := BASE_ATK + (floor - 1) * ATK_PER_FLOOR
	stats = StatSystem.new(hp, atk, BASE_DEF)
	xp_reward = BASE_XP_REWARD + (floor - 1) * XP_PER_FLOOR
