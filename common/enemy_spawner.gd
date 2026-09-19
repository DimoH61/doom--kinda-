@icon("uid://8iy6h7akyxx0")
class_name EnemySpawner
extends Node

@export var map_generator: MapGenerator
@export var enemy_scene: PackedScene
@export_range(0.01, 100.0) var spawn_rate: float = 1.0
@export_range(0.0, 1.0) var spawn_offset_range: float = 0.4
@export var enemy_lifetime: float = 10.0
@export var player: layer

func _ready() -> void:
	if not map_generator or not enemy_scene:
		print("Error: MapGenerator or EnemyScene not assigned!")
		return
		
	start_spawning()

func start_spawning() -> void:
	while not map_generator.is_generated:
		await get_tree().process_frame
		
	while true:
		await get_tree().create_timer(spawn_rate).timeout
		spawn_enemy()

func spawn_enemy() -> void:
	var cell_size: Vector3 = map_generator.grid_map.cell_size
	var size_x: int = map_generator.map_size_x
	var size_y: int = map_generator.map_size_y
	
	var rand_x: int = randi_range(-(size_x - 1), size_x - 2)
	var rand_z: int = randi_range(-(size_y - 1), size_y - 2)
	var max_height: int = 3
	var target_y: int = max_height

	while target_y >= -5 and map_generator.grid_map.get_cell_item(Vector3i(rand_x, target_y, rand_z)) == -1:
		target_y -= 1

	target_y += 1
		
	var offset_x: float = randf_range(-spawn_offset_range, spawn_offset_range) * (cell_size.x / 2.0)
	var offset_z: float = randf_range(-spawn_offset_range, spawn_offset_range) * (cell_size.z / 2.0)
	
	var spawn_pos: Vector3 = Vector3(
		rand_x * cell_size.x + (cell_size.x / 2.0) + offset_x,
		target_y * cell_size.y,
		rand_z * cell_size.z + (cell_size.z / 2.0) + offset_z
	)
	
	var new_enemy: Enemy = enemy_scene.instantiate() as Node3D
	new_enemy.player = player
	get_parent().add_child(new_enemy)
	new_enemy.global_position = spawn_pos
	
	setup_enemy_lifetime(new_enemy, enemy_lifetime)

func setup_enemy_lifetime(enemy_node: Node3D, lifetime: float) -> void:
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(enemy_node):
		enemy_node.queue_free()
