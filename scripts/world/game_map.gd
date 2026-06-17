extends TileMap

const ROOM_WIDTH = 15
const ROOM_HEIGHT = 10
const TILE_SIZE = 16
const ROOM_MID_X = ROOM_WIDTH / 2
const ROOM_MID_Y = ROOM_HEIGHT / 2

const FLOOR_SOURCE_ID = 1
const WALL_SOURCE_ID = 2
const FLOOR_ATLAS_COORD = Vector2i(0, 0)
const WALL_ATLAS_COORD = Vector2i(0, 0)
const FLOOR_LAYER = 0

@onready var player = $"../Player"
@onready var hud = $"../HUD"

var generator := DungeonGenerator.new()
var current_room_pos := Vector2i(0, 0)
var enemy_scene = preload("res://scenes/entities/enemy.tscn")
var enemies: Array = []

var current_floor := 1
var current_room_index := 0
var total_rooms := 0

func _ready() -> void:
	generator.generate()
	current_room_pos = generator.start_room
	_load_room(current_room_pos)
	player.enemy_killed.connect(_on_enemy_killed)
	hud.init(player, self)
	total_rooms = generator.rooms.size()
	
func _process(delta: float) -> void:
	_check_room_transition()

func _on_enemy_killed(enemy: Node) -> void:
	enemies.erase(enemy)	
	
	if enemies.is_empty():
		_on_room_cleared()
	
func _on_room_cleared() -> void:
	var room: DungeonGenerator.RoomData = generator.rooms[current_room_pos]
	room.cleared = true
	_open_doors()
	
	if current_room_pos == generator.end_room:
		_next_floor()

func _next_floor() -> void:
	generator.generate()
	current_room_pos = generator.start_room
	_load_room(current_room_pos)
	
	current_floor += 1
	total_rooms = generator.rooms.size()

func _check_room_transition() -> void:
	var room: DungeonGenerator.RoomData = generator.rooms[current_room_pos]
	
	if not room.cleared and room.grid_pos != generator.start_room:
		return
	
	var player_tile := Vector2i(player.position / TILE_SIZE)
	
	for door in room.doors:
		if door == DungeonGenerator.DIR_UP and player_tile.y < 0:
			_move_to_room(door)
		elif door == DungeonGenerator.DIR_DOWN and player_tile.y >= ROOM_HEIGHT:
			_move_to_room(door)
		elif door == DungeonGenerator.DIR_LEFT and player_tile.x < 0:
			_move_to_room(door)
		elif door == DungeonGenerator.DIR_RIGHT and player_tile.x >= ROOM_WIDTH:
			_move_to_room(door)

func _move_to_room(direction: Vector2i) -> void:
	var next_room_pos: Vector2i = current_room_pos + direction
	
	if not generator.rooms.has(next_room_pos):
		return
	
	current_room_pos = next_room_pos
	_load_room(current_room_pos, direction)

func _load_room(room_pos: Vector2i, enter_direction: Vector2i = Vector2i(0, 0)) -> void:
	var room: DungeonGenerator.RoomData = generator.rooms[room_pos]
	room.visited = true
	draw_room(room)
	
	if enter_direction == DungeonGenerator.DIR_UP:
		player.position = Vector2(ROOM_MID_X * TILE_SIZE, (ROOM_HEIGHT - 2) * TILE_SIZE)
	elif enter_direction == DungeonGenerator.DIR_DOWN:
		player.position = Vector2(ROOM_MID_X * TILE_SIZE, 2 * TILE_SIZE)
	elif enter_direction == DungeonGenerator.DIR_LEFT:
		player.position = Vector2((ROOM_WIDTH - 2) * TILE_SIZE, ROOM_MID_Y * TILE_SIZE)
	elif enter_direction == DungeonGenerator.DIR_RIGHT:
		player.position = Vector2(2 * TILE_SIZE, ROOM_MID_Y * TILE_SIZE)	
	else:
		player.position = Vector2(ROOM_MID_X * TILE_SIZE, ROOM_MID_Y * TILE_SIZE)
			
	_spawn_enemies()
	
	current_room_index = generator.room_order.find(room_pos) + 1

func draw_room(room: DungeonGenerator.RoomData) -> void:
	clear()
	
	for y in range(-1 , ROOM_HEIGHT + 1):
		for x in range(-1, ROOM_WIDTH + 1):
			set_cell(FLOOR_LAYER, Vector2i(x, y), WALL_SOURCE_ID, WALL_ATLAS_COORD)
			
	for y in range(0, ROOM_HEIGHT):
		for x in range(0, ROOM_WIDTH):
			set_cell(FLOOR_LAYER, Vector2i(x, y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
				
	for door in room.doors:
		_draw_door(door)

func _draw_door(direction: Vector2i) -> void:
	if direction == DungeonGenerator.DIR_UP:
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, -1), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, 0), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
	elif direction == DungeonGenerator.DIR_DOWN:		
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, ROOM_HEIGHT), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, ROOM_HEIGHT - 1), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
	elif direction == DungeonGenerator.DIR_LEFT:		
		set_cell(FLOOR_LAYER, Vector2i(-1 , ROOM_MID_Y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		set_cell(FLOOR_LAYER, Vector2i(0, ROOM_MID_Y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
	elif direction == DungeonGenerator.DIR_RIGHT:		
		set_cell(FLOOR_LAYER, Vector2i(ROOM_WIDTH , ROOM_MID_Y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		set_cell(FLOOR_LAYER, Vector2i(ROOM_WIDTH - 1, ROOM_MID_Y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)

func _spawn_enemies() -> void:
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()
	
	var room: DungeonGenerator.RoomData = generator.rooms[current_room_pos]
	
	if room.grid_pos == generator.start_room:
		return
	
	var spawn_pos := Vector2(ROOM_WIDTH / 4 * TILE_SIZE, ROOM_HEIGHT / 4 * TILE_SIZE)
	var enemy := enemy_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(enemy)
	enemy.init_pos(spawn_pos, player)
	enemies.append(enemy)	
	_close_doors()
	
func _close_doors() -> void:
	var room: DungeonGenerator.RoomData = generator.rooms[current_room_pos]
	for door in room.doors:
		_set_door(door, false)
		
func _open_doors() -> void:
	var room: DungeonGenerator.RoomData = generator.rooms[current_room_pos]
	for door in room.doors:
		_set_door(door, true)

func _set_door(direction: Vector2i, open: bool) -> void:
	var tile := WALL_SOURCE_ID if not open else FLOOR_SOURCE_ID
	var atlas := WALL_ATLAS_COORD if not open else FLOOR_ATLAS_COORD
	
	if direction == DungeonGenerator.DIR_UP:
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, -1), tile, atlas)
	elif direction == DungeonGenerator.DIR_DOWN:
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, ROOM_HEIGHT), tile, atlas)
	elif direction == DungeonGenerator.DIR_LEFT:
		set_cell(FLOOR_LAYER, Vector2i(-1, ROOM_MID_Y), tile, atlas)
	elif direction == DungeonGenerator.DIR_RIGHT:
		set_cell(FLOOR_LAYER, Vector2i(ROOM_WIDTH, ROOM_MID_Y), tile, atlas)

	

	
