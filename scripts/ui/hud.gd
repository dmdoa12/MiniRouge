extends CanvasLayer

@onready var hp_label = $HPLabel
@onready var floor_label = $FloorLabel
@onready var mini_map = $MiniMap

const ROOM_CELL_SIZE = 10
const ROOM_GAP = 2

var player: Node
var game_map : Node

func init(player_node: Node, game_map_node: Node) -> void:
	player = player_node
	game_map = game_map_node
	
func _process(delta: float) -> void:
	if player:
		hp_label.text = "HP: %d / %d" % [player.stats.hp, player.stats.max_hp]
	if game_map:
		floor_label.text = "층: %d 방: %d / %d" % [game_map.current_floor, game_map.current_room_index, game_map.total_rooms]
	update_minimap()
		
func update_minimap() -> void:
	for child in mini_map.get_children():
		child.queue_free()
		
	for room_pos in game_map.generator.rooms:
		var room: DungeonGenerator.RoomData = game_map.generator.rooms[room_pos]
		
		if not room.visited:
			continue
		
		var rect := ColorRect.new()
		rect.size = Vector2(ROOM_CELL_SIZE, ROOM_CELL_SIZE)
		rect.position = Vector2(room_pos * (ROOM_CELL_SIZE + ROOM_GAP))
		
		if room_pos == game_map.current_room_pos:
			rect.color = Color.YELLOW
		elif room.cleared:
			rect.color = Color(0.5, 0.5, 0.5)
		else:
			rect.color = Color.WHITE
			
		mini_map.add_child(rect)
			
