extends TileMap

enum layers {
	level0 = 0,
	level1 = 1,
	level2 = 2
}

const green_block_atlas_pos = Vector2i(2,0)
const white_boundary_block_atlas_pos = Vector2i(3,0)
const white_no_boundary_block_atlas_pos = Vector2i(3,1)
const black_block_atlas_pos = Vector2i(4,0)
const boundary_block_atlas_pos = Vector2i(0,1)
const blue_block_atlas_pos = Vector2i(0,0)
const main_source = 0

func place_boundaries(map: TileMap, level: int):
	var offsets = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
	]
	var used = map.get_used_cells(level)
	#var used1 = get_used_cells(layers.level1)
	for spot in used:
		for offset in offsets:
			var current_spot = spot + offset
			if map.get_cell_source_id(level, current_spot) == -1:
				map.set_cell(level, current_spot, main_source, boundary_block_atlas_pos)
	#for spot in used1:
		#for offset in offsets:
			#var current_spot = spot + offset
			#if get_cell_source_id(layers.level1, current_spot) == -1:
				#set_cell(layers.level1, current_spot, main_source, boundary_block_atlas_pos)
				
func remove_boundaries(map: TileMap, level: int):
	var used = map.get_used_cells(level)
	for spot in used:
		var atlas_coords = map.get_cell_atlas_coords(level, spot)
		if atlas_coords == boundary_block_atlas_pos:
			map.set_cell(level, spot)
	
func place_platform(map: TileMap):
	for y in range(3):
		for x in range(3):
			map.set_cell(layers.level0, Vector2i(2 + x, 2 + y), main_source, green_block_atlas_pos)
	map.set_cell(layers.level1, Vector2i(2, 2), main_source, blue_block_atlas_pos)

func replace_white_blocks(map: TileMap, level: int, place_boundary_blocks: bool):
	var used = map.get_used_cells(level)
	var check_for_block
	var set_block
	if place_boundary_blocks:
		check_for_block = white_no_boundary_block_atlas_pos
		set_block = white_boundary_block_atlas_pos
	else:
		check_for_block = white_boundary_block_atlas_pos
		set_block = white_no_boundary_block_atlas_pos
	for spot in used:
		if map.get_cell_atlas_coords(level, spot) == check_for_block:
			map.set_cell(level, spot, main_source, set_block)
	
func get_player_coords(map: TileMap) -> Vector2:
	return map.get_child(0).global_position

func get_tile_map_coords(map: TileMap, coords: Vector2) -> Vector2i:
	#print("coords: ", coords)
	return map.local_to_map(coords)
	
func get_blocks_next_level(map: TileMap, player_current_level: int) -> Array:
	#var blocks: Array[Vector2i] = []
	var offsets = [
		Vector2i(-1, -2),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(-2, -1),
	]
	var player_spot = TmFunctions.get_tile_map_coords(map, get_player_coords(map))
	for offset in offsets:
		var cell = player_spot + offset
		var source_id = map.get_cell_source_id(player_current_level + 1, cell)
		if source_id != -1:
			return [true, cell]
	
	return [false, Vector2.ZERO]

func get_blocks_lower_level(map: TileMap, player_current_level: int) -> Array:
	var offsets = [
		Vector2i(0, 1),
		Vector2i(1, 2),
		Vector2i(2, 1),
		Vector2i(1, 0),
	]
	var player_spot = TmFunctions.get_tile_map_coords(map, get_player_coords(map))
	for offset in offsets:
		var cell = player_spot + offset
		var source_current_level = map.get_cell_source_id(player_current_level, cell)
		var source_lower_level = map.get_cell_source_id(player_current_level - 1, cell)
		var atlas_coords_current_level = map.get_cell_atlas_coords(player_current_level, cell)
		print(atlas_coords_current_level, atlas_coords_current_level == boundary_block_atlas_pos)
		#If there is a block below and no block on this level
		if source_lower_level != -1:
			if source_current_level == -1: 
				return [true, cell]
			elif atlas_coords_current_level == boundary_block_atlas_pos:
				return [true, cell]
	
	return [false, Vector2.ZERO]

func move_player(player: CharacterBody2D, move_to: Vector2):
	player.position = move_to

func move_player_level(map: TileMap, player: CharacterBody2D, move_to: Vector2):
	if player.z_index == 1:
		remove_boundaries(map, 0)
		place_boundaries(map, 1)
		replace_white_blocks(map, 1, false)
		move_player(player, move_to)
		player.z_index += 1
		player.level += 1
	elif player.z_index == 2:
		remove_boundaries(map, 1)
		place_boundaries(map, 0)
		replace_white_blocks(map, 1, true)
		move_player(player, move_to)
		player.z_index -= 1
		player.level -= 1

func switch_scene(scene_path: String, player_position: Vector2, map: TileMap) -> void:
	var player = map.get_child(0)  # Assuming player is first child of TileMap
	# Store player data in metadata
	get_tree().set_meta("player_spawn_position", player_position)
	get_tree().set_meta("player_level", player.level)
	get_tree().set_meta("player_z_index", player.z_index)
	get_tree().change_scene_to_file(scene_path)
