extends CanvasLayer

@onready var floor_label = $StatusPanel/FloorLabel
@onready var hp_bar = $StatusPanel/HPBar
@onready var hp_label = $StatusPanel/HPBar/HPLabel
@onready var xp_bar = $StatusPanel/XPBar
@onready var level_label = $StatusPanel/XPBar/LevelLabel
@onready var mini_map = $MiniMap
@onready var slot_q = $SkillSlots/SlotQ
@onready var slot_w = $SkillSlots/SlotW
@onready var slot_e = $SkillSlots/SlotE
@onready var slot_r = $SkillSlots/SlotR
@onready var boss_bar = $BossBar
@onready var boss_label = $BossBar/BossLabel

const ROOM_CELL_SIZE = 10
const ROOM_GAP = 2

var player: Node
var game_map : Node
var hp_tween: Tween
var xp_tween: Tween
var boss_tween: Tween

func init(player_node: Node, game_map_node: Node) -> void:
	player = player_node
	game_map = game_map_node
	
func _process(delta: float) -> void:
	if player:
		hp_label.text = "HP: %d / %d" % [player.stats.hp, player.stats.max_hp]
		level_label.text = "Lv: %d" % player.level_system.level
	if game_map:
		floor_label.text = "층: %d" % game_map.current_floor
		
	hp_bar.max_value = player.stats.max_hp
	if hp_bar.value != player.stats.hp:
		if hp_tween:
			hp_tween.kill()
		hp_tween = create_tween()
		hp_tween.tween_property(hp_bar, "value", player.stats.hp, 0.3)
		
	xp_bar.max_value = player.level_system.xp_to_next
	if xp_bar.value != player.level_system.current_xp:
		if xp_tween:
			xp_tween.kill()
		xp_tween = create_tween()
		xp_tween.tween_property(xp_bar, "value", player.level_system.current_xp, 0.3)
		
	if is_instance_valid(game_map.boss):
		boss_bar.show()
		boss_label.text = "%d / %d" % [game_map.boss.stats.hp, game_map.boss.stats.max_hp]
		boss_bar.max_value = game_map.boss.stats.max_hp
		if boss_bar.value != game_map.boss.stats.hp:
			if boss_tween:
				boss_tween.kill()
			boss_tween = create_tween()
			boss_tween.tween_property(boss_bar, "value", game_map.boss.stats.hp, 0.3)
	else:
		boss_bar.hide()
	
	update_minimap()
	_update_skill_slots()
	
func _update_skill_slots() -> void:
	var slots := {"q": slot_q, "w": slot_w, "e": slot_e, "r": slot_r}
	for key in slots:
		var skill = player.skill_slots[key]
		slots[key].set_slot(key, skill)
		
func update_minimap() -> void:
	for child in mini_map.get_children():
		child.queue_free()
	var current: Vector2i = game_map.player_grid_pos()	
	for room_pos in game_map.generator.rooms:
		var room: DungeonGenerator.RoomData = game_map.generator.rooms[room_pos]
		
		if not room.visited:
			continue
		
		var rect := ColorRect.new()
		rect.size = Vector2(ROOM_CELL_SIZE, ROOM_CELL_SIZE)
		rect.position = Vector2(room_pos * (ROOM_CELL_SIZE + ROOM_GAP))
		
		if room_pos == current:
			rect.color = Color.YELLOW
		elif room.cleared:
			rect.color = Color(0.5, 0.5, 0.5)
		else:
			rect.color = Color.WHITE
			
		mini_map.add_child(rect)
			
