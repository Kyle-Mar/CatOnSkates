extends Node2D

var tilemap : TileMap
var bounds : Vector2i
var astargrid : AStarGrid2D
signal initialize

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_initialize():
	astargrid = AStarGrid2D.new()
	astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astargrid.region = Rect2i(-bounds.x, -bounds.y, bounds.x*2, bounds.y*2)
	astargrid.cell_size = Vector2i(16,20)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astargrid.update()

func _process(delta):
	if tilemap == null:
		return
	if bounds == null:
		return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		var points = get_next_point(enemy.position, PlayerInfo.position)
#		$Line2D.clear_points()
#		$Line2D.width = 10
#		for point in points:
#			$Line2D.add_point(
#				tilemap.to_global(
#				tilemap.map_to_local(
#				point
#			)))
		if(len(points) > 1):
			#print(points[0], tilemap.local_to_map(get_global_mouse_position()))
			enemy.move_to(
				tilemap.to_global(
				tilemap.map_to_local(
				points[0])), delta
			)
			#enemy.move_to(Vector2(points[1])-Vector2(points[0]))
		else:
			enemy.move_to(enemy.position, delta)
			


func get_next_point(start, end):
	if not end:
		return []
	
	var path = astargrid.get_id_path(
		tilemap.local_to_map(start),
		tilemap.local_to_map(end)
	).slice(1)
	
	return path
	



