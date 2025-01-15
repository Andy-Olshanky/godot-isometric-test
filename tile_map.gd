extends TileMap

enum layers {
	level0 = 0,
	level1 = 1,
	level2 = 2
}

const green_block_atlas_pos = Vector2i(2,0)
const boundary_block_atlas_pos = Vector2i(0,1)
const blue_block_atlas_pos = Vector2i(0,0)
const main_source = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_platform()
	place_boundaries()
	#test_this()
	pass
	
func place_boundaries():
	var offsets = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
	]
	var used = get_used_cells(layers.level0)
	for spot in used:
		for offset in offsets:
			var current_spot = spot + offset
			if get_cell_source_id(layers.level0, current_spot) == -1:
				set_cell(layers.level0, current_spot, main_source, boundary_block_atlas_pos)
	
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
	if Input.is_action_just_pressed("jump"):
		print(get_blocks_next_level(self.get_child(0).level))
	#pass
	
func get_player_coords() -> Vector2:
	return self.get_child(0).global_position

func get_tile_map_coords(coords: Vector2) -> Vector2i:
	return local_to_map(coords)
	
func get_blocks_next_level(player_level: int) -> Array[Vector2i]:
	var blocks: Array[Vector2i] = []
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
			blocks.append(cell)
	
	return blocks
