extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TmFunctions.place_platform(self)
	TmFunctions.place_boundaries(self, 0)
	
	var player = get_child(0)  # Assuming player is first child of TileMap
	
	if get_tree().has_meta("player_spawn_position"):
		player.position = get_tree().get_meta("player_spawn_position")
		player.level = get_tree().get_meta("player_level")
		player.z_index = get_tree().get_meta("player_z_index")
		
		# Clean up metadata
		get_tree().remove_meta("player_spawn_position")
		get_tree().remove_meta("player_level")
		get_tree().remove_meta("player_z_index")
	#test_this()
	pass
	

#func test_this():
	#var used0 = get_used_cells(TmFunctions.layers.level0)
	#var used1 = get_used_cells(TmFunctions.layers.level1)
	#var used2 = get_used_cells(TmFunctions.layers.level2)
	#
	#for spot in used0:
		#print("level 0: ", get_cell_source_id(0, spot), spot)
		#print("\tLevel 1: ", get_cell_source_id(1, spot), spot)
	#for spot in used1:
		#print("level 1: ", get_cell_source_id(1, spot), spot)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(get_tile_map_coords(get_player_coords()))
	var player = self.get_child(0)
	if Input.is_action_just_pressed("jump"):
		#print(player.level)
		var coords
		if player.level == 0:
			coords = TmFunctions.get_blocks_next_level(self, player.level)
		else:
			coords = TmFunctions.get_blocks_lower_level(self, player.level)
		if (coords[0]):
			TmFunctions.move_player_level(self, player, map_to_local(coords[1]))
			#print("map coords: ", coords[1], " | local coords", map_to_local(coords[1]))
			#remove_boundaries(0)
			#place_boundaries(1)
			#move_player(player, map_to_local(coords[1]))
	if Input.is_action_just_pressed("other"):
		var cell_atlas = self.get_cell_atlas_coords(player.level, TmFunctions.get_tile_map_coords(self, TmFunctions.get_player_coords(self)))
		if cell_atlas == TmFunctions.black_block_atlas_pos:
			#print("on black block")
			TmFunctions.switch_scene("res://secondary.tscn", Vector2(16, 0), self)
	#pass
	
