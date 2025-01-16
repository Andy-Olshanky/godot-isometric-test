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
var boundary_flag = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_platform()
	place_boundaries(0)
	#test_this()
	pass
	
func place_boundaries(level: int):
	var offsets = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
	]
	var used = get_used_cells(level)
	#var used1 = get_used_cells(layers.level1)
	for spot in used:
		for offset in offsets:
			var current_spot = spot + offset
			if get_cell_source_id(level, current_spot) == -1:
				set_cell(level, current_spot, main_source, boundary_block_atlas_pos)
	#for spot in used1:
		#for offset in offsets:
			#var current_spot = spot + offset
			#if get_cell_source_id(layers.level1, current_spot) == -1:
				#set_cell(layers.level1, current_spot, main_source, boundary_block_atlas_pos)
				
func remove_boundaries(level: int):
	var used = get_used_cells(level)
	for spot in used:
		var atlas_coords = get_cell_atlas_coords(level, spot)
		if atlas_coords == boundary_block_atlas_pos:
			set_cell(level, spot)
	
func place_platform():
	for y in range(3):
		for x in range(3):
			set_cell(layers.level0, Vector2i(2 + x, 2 + y), main_source, green_block_atlas_pos)
	set_cell(layers.level1, Vector2i(2, 2), main_source, blue_block_atlas_pos)

func test_this():
	var used0 = get_used_cells(layers.level0)
	var used1 = get_used_cells(layers.level1)
	var used2 = get_used_cells(layers.level2)
	
	for spot in used0:
		print("level 0: ", get_cell_source_id(0, spot), spot)
		print("\tLevel 1: ", get_cell_source_id(1, spot), spot)
	for spot in used1:
		print("level 1: ", get_cell_source_id(1, spot), spot)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(get_tile_map_coords(get_player_coords()))
	var player = self.get_child(0)
	if Input.is_action_just_pressed("jump"):
		#print(player.level)
		var coords = get_blocks_next_level(player.level)
		if (coords[0]):
			#move_player_level(player, map_to_local(coords[1]))
			print("map coords: ", coords[1], " | local coords", map_to_local(coords[1]))
			#remove_boundaries(0)
			#place_boundaries(1)
			#move_player(player, map_to_local(coords[1]))
	#if Input.is_action_just_pressed("other"):
		#if boundary_flag:
			#remove_boundaries(0)
		#else:
			#place_boundaries(0)
		#boundary_flag = !boundary_flag
	#pass
	
func replace_white_blocks(level: int):
	var used = get_used_cells(level)
	for spot in used:
		if get_cell_atlas_coords(level, spot) == white_boundary_block_atlas_pos:
			set_cell(level, spot, main_source, white_no_boundary_block_atlas_pos)
	
func get_player_coords() -> Vector2:
	return self.get_child(0).global_position

func get_tile_map_coords(coords: Vector2) -> Vector2i:
	print("coords: ", coords)
	return local_to_map(coords)
	
func get_blocks_next_level(player_level: int) -> Array:
	#var blocks: Array[Vector2i] = []
	var offsets = [
		Vector2i(-1, -2),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(-2, -1),
	]
	var player_spot = get_tile_map_coords(get_player_coords())
	for offset in offsets:
		var cell = player_spot + offset
		var source_id = get_cell_source_id(player_level + 1, cell)
		if source_id != -1:
			return [true, cell]
	
	return [false, Vector2.ZERO]

func get_blocks_lower_level(player_level: int) -> Array:
	var offsets = [
		Vector2i(0, 1),
		Vector2i(1, 2),
		Vector2i(2, 1),
		Vector2i(1, 0),
	]
	var player_spot = get_tile_map_coords(get_player_coords())
	for offset in offsets:
		var cell = player_spot + offset
		var source_current_level = get_cell_source_id(player_level, cell)
		var source_lower_level = get_cell_source_id(player_level - 1, cell)
		#If there is a block below and no block on this level
		if source_lower_level != -1 and source_current_level == -1:
			return [true, cell]
	
	return [false, Vector2.ZERO]

func move_player(player: CharacterBody2D, move_to: Vector2):
	player.position = move_to

func move_player_level(player: CharacterBody2D, move_to: Vector2):
	if player.z_index == 1:
		player.z_index += 1
		remove_boundaries(0)
		place_boundaries(1)
		replace_white_blocks(1)
		move_player(player, move_to)
		
