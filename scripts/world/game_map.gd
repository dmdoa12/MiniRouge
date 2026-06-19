extends TileMap

const ROOM_WIDTH = 25
const ROOM_HEIGHT = 18
const ROOM_GAP = 1
const DOOR_WIDTH = 3   # 문 폭(타일)

const TILE_SIZE = 16
const ROOM_MID_X = ROOM_WIDTH / 2
const ROOM_MID_Y = ROOM_HEIGHT / 2
const ENEMIES_PER_ROOM = 3
const SPAWN_MARGIN = 3   # 벽에서 떨어뜨릴 안전 여백(타일)

const FLOOR_SOURCE_ID = 1
const WALL_SOURCE_ID = 2
const FLOOR_ATLAS_COORD = Vector2i(0, 0)
const WALL_ATLAS_COORD = Vector2i(0, 0)
const FLOOR_LAYER = 0

@onready var player = $"../Player"
@onready var hud = $"../HUD"
@onready var skill_select = $"../SkillSelection"

var enemy_scene = preload("res://scenes/entities/enemy.tscn")
var stairs_scene = preload("res://scenes/entities/stairs.tscn")

var generator := DungeonGenerator.new()
var enemies: Array = []
var current_stairs: Node = null
var current_floor := 1

func _ready() -> void:
	generator.generate()
	draw_full_map()
	_place_player_at(generator.start_room)
	_spawn_all_enemies()
	player.enemy_killed.connect(_on_enemy_killed)
	hud.init(player, self)
	skill_select.skill_chosen.connect(_on_skill_chosen)
	player.player_leveled_up.connect(_on_player_leveled_up)

func _on_player_leveled_up(_new_level: int) -> void:
	skill_select.show_cards(player.owned_skill_ids())

func room_origin(grid_pos: Vector2i) -> Vector2i:
	return Vector2i(grid_pos.x * (ROOM_WIDTH + ROOM_GAP), grid_pos.y * (ROOM_HEIGHT + ROOM_GAP))

func player_grid_pos() -> Vector2i:
	var tile_x := int(player.position.x / TILE_SIZE)
	var tile_y := int(player.position.y / TILE_SIZE)
	return Vector2i(tile_x / (ROOM_WIDTH + ROOM_GAP), tile_y / (ROOM_HEIGHT + ROOM_GAP))

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
	_carve_doors()

func _place_player_at(grid_pos: Vector2i) -> void:
	var origin := room_origin(grid_pos)
	player.position = Vector2((origin.x + ROOM_MID_X) * TILE_SIZE, (origin.y + ROOM_MID_Y) * TILE_SIZE)

func _on_skill_chosen(skill_id: String) -> void:
	player.add_skill(skill_id)

func _spawn_all_enemies() -> void:
	for grid_pos in generator.rooms:
		if grid_pos == generator.start_room:
			continue
		var origin := room_origin(grid_pos)
		for i in range(ENEMIES_PER_ROOM):
			var tile_x := randi_range(SPAWN_MARGIN, ROOM_WIDTH - 1 - SPAWN_MARGIN)
			var tile_y := randi_range(SPAWN_MARGIN, ROOM_HEIGHT - 1 - SPAWN_MARGIN)
			var spawn_pos := Vector2((origin.x + tile_x) * TILE_SIZE, (origin.y + tile_y) * TILE_SIZE)
			var enemy := enemy_scene.instantiate()
			get_tree().current_scene.add_child.call_deferred(enemy)
			enemy.init_pos(spawn_pos, player)
			enemies.append(enemy)

func _on_enemy_killed(enemy: Node) -> void:
	enemies.erase(enemy)
	if enemies.is_empty():
		_on_floor_cleared()

func _on_floor_cleared() -> void:
	var origin := room_origin(generator.end_room)
	var stairs := stairs_scene.instantiate()
	get_tree().current_scene.add_child(stairs)
	stairs.position = Vector2((origin.x + ROOM_MID_X) * TILE_SIZE, (origin.y + ROOM_MID_Y) * TILE_SIZE)
	current_stairs = stairs
	stairs.player_entered.connect(_on_stairs_entered)

func _on_stairs_entered() -> void:
	_next_floor()

func _next_floor() -> void:
	await Transition.fade_to_black()
	current_floor += 1
	if current_stairs:
		current_stairs.queue_free()
		current_stairs = null
	generator.generate()
	draw_full_map()
	_place_player_at(generator.start_room)
	_spawn_all_enemies()
	await Transition.fade_from_black()		
			
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
