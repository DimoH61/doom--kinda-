@icon("uid://7svswgd83epj")
class_name MapGenerator
extends Node

enum {TILE_AIR, TILE_BLOCK, TILE_SLOPE}

@export_range(1, 100) var map_size_x := 10
@export_range(1, 100) var map_size_y := 10

@export var noise : FastNoiseLite
@export var grid_map: GridMap

var is_generated: bool = false
var half_width = map_size_x / 2
var half_height = map_size_y / 2

func _ready() -> void:
	generate_floor(map_size_x, map_size_y)
	generate_slopes(map_size_x, map_size_y)
	generate_walls(map_size_x, map_size_y)
	grid_map.set_cell_item(Vector3i(0, 0, 0), -1, 0)
	is_generated = true
	

func get_neighbour(x: int, y: int, block_id: int, height: int) -> Vector2i:
	if grid_map.get_cell_item(Vector3i(x + 1, height, y)) == block_id:
		return Vector2i(x + 1, y)
	if grid_map.get_cell_item(Vector3i(x - 1, height, y)) == block_id:
		return Vector2i(x - 1, y)
	if grid_map.get_cell_item(Vector3i(x, height, y + 1)) == block_id:
		return Vector2i(x, y + 1)
	if grid_map.get_cell_item(Vector3i(x, height, y - 1)) == block_id:
		return Vector2i(x, y - 1)
	return Vector2i(x, y)


func generate_floor(width: int, height: int) -> void:
	for x in range(-width, width):
		for y in range(-height, height):
			var noise_val: float = noise.get_noise_2d(x, y)
			
			if noise_val >= -0.0:
				grid_map.set_cell_item(Vector3i(x, -1, y), 1, 0)

func generate_slopes(width: int, height: int) -> void:
	for x in range(-width, width):
		for y in range(-height, height):
			var floor_neighbour = get_neighbour(x, y, 1, -1)
			var slope_neighbour = get_neighbour(x, y, 2, 0)
			
			if floor_neighbour == Vector2i(x, y):
				continue
			
			if grid_map.get_cell_item(Vector3i(x, -1, y)) == 1:
				continue
			
			if floor_neighbour == Vector2i(x + 1, y) and not slope_neighbour == Vector2i(x, y - 1) and not slope_neighbour == Vector2i(x, y + 1) and not slope_neighbour == Vector2i(x - 1, y):
				grid_map.set_cell_item(Vector3i(x, 0, y), 2, 0)
			
			if floor_neighbour == Vector2i(x - 1, y) and not slope_neighbour == Vector2i(x, y - 1) and not slope_neighbour == Vector2i(x, y + 1) and not slope_neighbour == Vector2i(x + 1, y):
				grid_map.set_cell_item(Vector3i(x, 0, y), 2, 10)
			
			if floor_neighbour == Vector2i(x, y + 1) and not slope_neighbour == Vector2i(x - 1, y) and not slope_neighbour == Vector2i(x + 1, y) and not slope_neighbour == Vector2i(x, y - 1):
				grid_map.set_cell_item(Vector3i(x, 0, y), 2, 22)
			if floor_neighbour == Vector2i(x, y - 1) and not slope_neighbour == Vector2i(x - 1, y) and not slope_neighbour == Vector2i(x + 1, y) and not slope_neighbour == Vector2i(x, y + 1):
				grid_map.set_cell_item(Vector3i(x, 0, y), 2, 16)

func generate_walls(width: int, height: int) -> void:
	for x in range(-width, width):
		for y in range(-height, height):
			if grid_map.get_cell_item(Vector3i(x, 0, y)) == -1 and grid_map.get_cell_item(Vector3i(x, -1, y)) == -1:
				grid_map.set_cell_item(Vector3i(x, 0, y), 1, 0)
