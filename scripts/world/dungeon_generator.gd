class_name DungeonGenerator

class RoomData:
	var grid_pos: Vector2i
	var doors: Array[Vector2i] = []
	var cleared: bool = false
	var visited: bool = false
	
	func _init(pos: Vector2i) -> void:
		grid_pos = pos

const GRID_SIZE = 5
const MAX_ROOMS = 8
const MIN_ROOMS = 5
const DIR_UP = Vector2i(0, -1)
const DIR_DOWN = Vector2i(0, 1)
const DIR_LEFT = Vector2i(-1, 0)
const DIR_RIGHT = Vector2i(1, 0)

var rng := RandomNumberGenerator.new()
var rooms: Dictionary = {}
var room_order: Array[Vector2i] = []
var start_room: Vector2i
var end_room: Vector2i

func generate() -> void:
	rng.randomize()
	rooms.clear()
	room_order.clear()
	
	var current := Vector2i(GRID_SIZE / 2, GRID_SIZE / 2)
	start_room = current
	
	while room_order.size() < MAX_ROOMS:
		if not rooms.has(current):
			rooms[current] = RoomData.new(current)
			room_order.append(current)
			
		var directions := [DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT]
		directions.shuffle()
		
		var moved := false
		for dir in directions:
			var next: Vector2i = current + dir
			if next.x >= 0 and next.x < GRID_SIZE and next.y >= 0 and next.y < GRID_SIZE:
				current = next
				moved = true
				break
			
			if not moved:
				break
	end_room = room_order[-1]
	_connect_rooms()
	
	print("생성된 방 수: ", rooms.size())
	print("room_order 수: ", room_order.size())
	
func _connect_rooms() -> void:
	var directions := [DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT]
	
	for room_pos in rooms:
		for dir in directions:
			var neighbor: Vector2i = room_pos + dir
			if rooms.has(neighbor):
				rooms[room_pos].doors.append(dir)
			
func get_start_room() -> RoomData:
	return rooms[start_room]
	
func get_end_room() -> RoomData:
	return rooms[end_room]
	
func get_room(grid_pos: Vector2i) -> RoomData:
	return rooms.get(grid_pos, null)
	
