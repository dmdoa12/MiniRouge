@tool
extends EditorScript

func _run() -> void:
	var floor_img := Image.create(16, 16, false, Image.FORMAT_RGB8)
	floor_img.fill(Color(0.4, 0.3, 0.2))  # 갈색 바닥
	floor_img.save_png("res://assets/tilesets/floor.png")

	var wall_img := Image.create(16, 16, false, Image.FORMAT_RGB8)
	wall_img.fill(Color(0.6, 0.6, 0.6))  # 회색 벽
	wall_img.save_png("res://assets/tilesets/wall.png")
	
	var enemy_img := Image.create(16, 16, false, Image.FORMAT_RGB8)
	enemy_img.fill(Color(0.8, 0.2, 0.2))  # 빨간색
	enemy_img.save_png("res://assets/tilesets/enemy.png")

	print("타일 이미지 생성 완료")
