extends TileMap

const ROOM_WIDTH = 25
const ROOM_HEIGHT = 18
const ROOM_GAP = 1
const DOOR_WIDTH = 3   # 문 폭(타일)

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
@onready var skill_select = $"../SkillSelection"

var enemy_scene = preload("res://scenes/entities/enemy.tscn")
var door_scene = preload("res://scenes/entities/door.tscn")

var generator := DungeonGenerator.new()
var current_room_pos := Vector2i(0, 0)
var enemies: Array = []
var is_transitioning := false

var current_floor := 1
var current_room_index := 0
var total_rooms := 0

func _ready() -> void:
	generator.generate()
	current_room_pos = generator.start_room
	draw_full_map()
	_place_player_at(generator.start_room)
	player.enemy_killed.connect(_on_enemy_killed)
	hud.init(player, self)
	total_rooms = generator.rooms.size()
	skill_select.skill_chosen.connect(_on_skill_chosen)
	
func _process(delta: float) -> void:
	_check_door_transition()

func room_origin(grid_pos: Vector2i) -> Vector2i:
	return Vector2i(grid_pos.x * (ROOM_WIDTH + ROOM_GAP), grid_pos.y * (ROOM_HEIGHT + ROOM_GAP))
	
func _draw_room_tiles(origin: Vector2i) -> void:
	for y in range(-1, ROOM_HEIGHT + 1):
		for x in range(-1, ROOM_WIDTH + 1):
			set_cell(FLOOR_LAYER, origin + Vector2i(x, y), WALL_SOURCE_ID, WALL_ATLAS_COORD)
	
	for y in range(0, ROOM_HEIGHT):
		for x in range(0, ROOM_WIDTH):
			set_cell(FLOOR_LAYER, origin + Vector2i(x, y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)

func draw_full_map() -> void:
	clear()
	for grid_pos in generator.rooms:
		var room: DungeonGenerator.RoomData = generator.rooms[grid_pos]
		room.visited = true
		_draw_room_tiles(room_origin(grid_pos))
	_carve_doors()          # ← 이 줄 추가 (for 밖, 함수 안)
		
func _place_player_at(grid_pos: Vector2i) -> void:
	var origin := room_origin(grid_pos)
	player.position = Vector2((origin.x + ROOM_MID_X) * TILE_SIZE, (origin.y + ROOM_MID_Y) * TILE_SIZE)	

func _on_skill_chosen(skill_id: String) -> void:
	player.add_skill(skill_id)

func _check_door_transition() -> void:
	for door in get_tree().get_nodes_in_group("doors"):
		if door.locked:
			continue
		if player.position.distance_to(door.global_position) < 16.0:
			_move_to_room(door.direction)
			break

func _on_enemy_killed(enemy: Node) -> void:
	enemies.erase(enemy)	
	
	if enemies.is_empty():
		_on_room_cleared()
	
func _on_room_cleared() -> void:
	var room: DungeonGenerator.RoomData = generator.rooms[current_room_pos]
	room.cleared = true
	_open_doors()
	
	skill_select.show_cards()
	
	if current_room_pos == generator.end_room:
		_next_floor()

func _next_floor() -> void:
	generator.generate()
	current_room_pos = generator.start_room
	_load_room(current_room_pos)
	
	current_floor += 1
	total_rooms = generator.rooms.size()

func _move_to_room(direction: Vector2i) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	var next_room_pos: Vector2i = current_room_pos + direction
	
	if not generator.rooms.has(next_room_pos):
		is_transitioning = false
		return
	
	current_room_pos = next_room_pos
	_load_room(current_room_pos, direction)
	is_transitioning = false

func _load_room(room_pos: Vector2i, enter_direction: Vector2i = Vector2i(0, 0)) -> void:
	for door in get_tree().get_nodes_in_group("doors"):
		door.queue_free()
	
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
	var door := door_scene.instantiate()
	
	if direction == DungeonGenerator.DIR_UP:
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, -1), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, 0), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		door.position = Vector2(ROOM_MID_X * TILE_SIZE, -TILE_SIZE)
	elif direction == DungeonGenerator.DIR_DOWN:		
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, ROOM_HEIGHT), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		set_cell(FLOOR_LAYER, Vector2i(ROOM_MID_X, ROOM_HEIGHT - 1), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		door.position = Vector2(ROOM_MID_X * TILE_SIZE, ROOM_HEIGHT * TILE_SIZE)
	elif direction == DungeonGenerator.DIR_LEFT:		
		set_cell(FLOOR_LAYER, Vector2i(-1 , ROOM_MID_Y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		set_cell(FLOOR_LAYER, Vector2i(0, ROOM_MID_Y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		door.position = Vector2(-TILE_SIZE, ROOM_MID_Y * TILE_SIZE)
	elif direction == DungeonGenerator.DIR_RIGHT:		
		set_cell(FLOOR_LAYER, Vector2i(ROOM_WIDTH , ROOM_MID_Y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		set_cell(FLOOR_LAYER, Vector2i(ROOM_WIDTH - 1, ROOM_MID_Y), FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)
		door.position = Vector2(ROOM_WIDTH * TILE_SIZE, ROOM_MID_Y * TILE_SIZE)
	
	add_child(door)
	door.init(direction, self)

func _spawn_enemies() -> void:
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()
	
	var room: DungeonGenerator.RoomData = generator.rooms[current_room_pos]
	
	if room.grid_pos == generator.start_room:
		return
		
	if room.cleared:
		return
	
	var spawn_pos := Vector2(ROOM_WIDTH / 4 * TILE_SIZE, ROOM_HEIGHT / 4 * TILE_SIZE)
	var enemy := enemy_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(enemy)
	enemy.init_pos(spawn_pos, player)
	enemies.append(enemy)	
	call_deferred("_close_doors")
	
func _close_doors() -> void:
	for door in get_tree().get_nodes_in_group("doors"):
		door.lock()
		
func _open_doors() -> void:
	for door in get_tree().get_nodes_in_group("doors"):
		door.unlock()

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

func _carve_doors() -> void:
	for grid_pos in generator.rooms:
		var room: DungeonGenerator.RoomData = generator.rooms[grid_pos]
		var origin := room_origin(grid_pos)
		for dir in room.doors:
			_carve_door(origin, dir)

func _carve_door(origin: Vector2i, direction: Vector2i) -> void:
	var half := DOOR_WIDTH / 2
	for i in range(-half, half + 1):
		var cell: Vector2i
		if direction == DungeonGenerator.DIR_RIGHT:
			cell = Vector2i(origin.x + ROOM_WIDTH, origin.y + ROOM_MID_Y + i)
		elif direction == DungeonGenerator.DIR_LEFT:
			cell = Vector2i(origin.x - 1, origin.y + ROOM_MID_Y + i)
		elif direction == DungeonGenerator.DIR_DOWN:
			cell = Vector2i(origin.x + ROOM_MID_X + i, origin.y + ROOM_HEIGHT)
		else: # DIR_UP
			cell = Vector2i(origin.x + ROOM_MID_X + i, origin.y - 1)
		set_cell(FLOOR_LAYER, cell, FLOOR_SOURCE_ID, FLOOR_ATLAS_COORD)

	
