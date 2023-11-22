extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_global_tile_position(pos : Vector2i):
	return to_global(map_to_local(pos))
