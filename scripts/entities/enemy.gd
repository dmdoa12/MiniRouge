extends CharacterBody2D

const SPEED = 50.0
var stats := StatSystem.new(10, 3, 1)
var xp_reward := 2
var attack_cooldown := 0.0
var attack_rate := 1.0
var knockback_velocity := Vector2.ZERO
var player: Node

func init_pos(start_pos: Vector2, player_node: Node) -> void:
	player = player_node
	position = start_pos

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
