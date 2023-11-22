extends Node
@export var target_tilemap : NodePath
@export_category("Settings")
@export var start_on_ready = true
@export var bounds: Vector2i

signal generation_start
signal minimum_path_done


var direction : Vector2i
var walk_pos : Vector2i = Vector2i(0,0)
var floor_list: Array[Vector2] = []

var num_floors = 0
var exit_spawned:bool = false

var door : Node2D

const door_scene = preload("res://scenes/exit_door.tscn")

enum ValidPos{
	BOUNDSX = 1,
	BOUNDSY = 2,
	ZEROX = 3,
	ZEROY = 4,
	VALID = 5,
}

const INVALID_CELL = Vector2i(-1,-1)
const WALK_PATH = Vector2i(3,0)
const WALK_PATH_ROT = Vector2i(5,0)
const WALK_PATH_SHAD = Vector2i(4,0)
const WALK_PATH_SHAD_ROT = Vector2i(4,1)
const TOP_WALL = Vector2i(0,0)
const WALL_NORMAL = Vector2i(1,0)
const WALL_DIST = Vector2i(2,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	direction = Vector2i(0,1)
	if start_on_ready:
		start()

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_P:
				reset()
		
func start():
	assert(target_tilemap != null)
	generation_start.emit()
	var target_node = get_node(target_tilemap)
	######## INITIALIZE PATHFINDING ########
	$Pathfinding.bounds = bounds*2
	$Pathfinding.tilemap = target_node
	$Pathfinding.initialize.emit()
	#target_node.collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_SHOW
	
	#########MINIMUM PATH AND ROOM GENERATION########
	random_walk(target_node)
		
	######FILL AREA AROUND AND PLACE TOP WALLS AND OTHER WALLS##########
	for i in range(-bounds.y*4, bounds.y*4):
		for j in range(-bounds.x*4, bounds.x*4):
			#print(target_node.get_cell_atlas_coords(0, Vector2i(j,i)))
			if target_node.get_cell_atlas_coords(0, Vector2i(j,i)) == INVALID_CELL:
				if($Pathfinding.astargrid.is_in_boundsv(Vector2i(j,i))):
					$Pathfinding.astargrid.set_point_solid(Vector2i(j,i))
				if is_walk_path(target_node.get_cell_atlas_coords(0, Vector2i(j,i+1))):
					target_node.set_cell(0, Vector2i(j,i), 4, TOP_WALL)
					#figure out how to randomize door position but guarantee
					# that it still exists
					# we could add all valid doorpositions to a list or something but
					#thats a nice to have not a need to have
					if not exit_spawned:
						if is_valid_door_position(target_node, Vector2i(j,i)):
							door = door_scene.instantiate()
							door.global_position = target_node.get_global_tile_position(Vector2i(j,i)) as Vector2 + Vector2(0,.55)
							door.connect("door_entered", reset)
							_global.get_root_game().add_child.call_deferred(door)
							exit_spawned = true
				else:
					if randi()%20 == 0:
						target_node.set_cell(0, Vector2i(j,i), 4, WALL_NORMAL)
					else:
						target_node.set_cell(0, Vector2i(j,i), 4, WALL_DIST)
				
			if is_walk_path(target_node.get_cell_atlas_coords(0, Vector2i(j,i))):
				if target_node.get_cell_atlas_coords(0, Vector2i(j,i-1)) == TOP_WALL:
					target_node.set_cell(0, Vector2i(j,i), 4, WALK_PATH_SHAD)
				
	EventBus.player_position_picked.emit(get_player_position())
	
	

	#minimum_path_done.emit()
func random_walk(target_node):
	while num_floors < 1000:
		if randi() % 10 == 1: # ten percent chance
			direction = get_new_direction(direction)
		if randi() % 15 == 1: # 5 percent chance
			splat_room(target_node, 5, 5, walk_pos)			
		walk_pos += direction
		var validity = validate_pos(walk_pos)
		match validity:
			ValidPos.BOUNDSX:
				walk_pos = Vector2i(bounds.x, walk_pos.y)
				#print('bounds')
			ValidPos.BOUNDSY:
				walk_pos = Vector2i(walk_pos.x, bounds.y)
				#print('bounds')
			ValidPos.ZEROX:
				walk_pos = Vector2i(0, walk_pos.y)
				#print('bounds')
			ValidPos.ZEROY:
				walk_pos = Vector2i(walk_pos.x, 0)
				#print('bounds')
			ValidPos.VALID:
				pass
				#print('valid')
		if validity != ValidPos.VALID:
			direction = -direction
			walk_pos += direction
		splat_path(target_node, walk_pos, direction)


func reset():
	print("RESETTING")
	assert(target_tilemap != null)
	var target_node = get_node(target_tilemap)
	
	floor_list.clear()
	walk_pos = Vector2i(0,0)
	num_floors = 0
	exit_spawned = false
	for i in range(-bounds.y*2, bounds.y*2):
		for j in range(-bounds.x*2, bounds.x*2):
			target_node.set_cell(0, Vector2i(j,i), 4, INVALID_CELL)
			if($Pathfinding.astargrid.is_in_boundsv(Vector2i(j,i))):
					$Pathfinding.astargrid.set_point_solid(Vector2i(j,i), false)
	door.queue_free()
	start()
	

func get_new_direction(cur_dir: Vector2i) -> Vector2i:
	var new_dir = random_direction()
	#while new_dir == -cur_dir:
	#	new_dir = random_direction()
	return new_dir

func random_direction() -> Vector2i:
	var eps = randi()%4
	match eps:
		0:
			#up
			return Vector2i(0,1)
		1:
			#down
			return  Vector2i(0,-1)
		2:
			#right
			return Vector2i(1, 0)
		_:
			#left
			return Vector2i(-1,0)
	
func splat_room(tilemap: TileMap, half_width: int, half_height: int, position: Vector2i):
	for i in range(-half_width, half_width):
		for j in range(-half_height, half_height):
			if validate_pos(position + Vector2i(i,j)) != ValidPos.VALID:
				return
	for i in range(-half_width, half_width):
		for j in range(-half_height, half_height):
			num_floors+=1
			create_floor_tile(tilemap, Vector2i(i,j))

func splat_path(tilemap: TileMap, position: Vector2i, direction: Vector2i):
	if direction.x == 0:
		for i in range(-1, 2, 1):
			if validate_pos(position + Vector2i(i,0)) != ValidPos.VALID:
				pass
		for i in range(-1, 2, 1):
			create_floor_tile(tilemap, position + Vector2i(i,0))
			num_floors += 1
	else:
		for i in range(-1, 2, 1):
			if validate_pos(position + Vector2i(0,i)) != ValidPos.VALID:
				pass
			create_floor_tile(tilemap, position + Vector2i(0,i))
			num_floors += 1

func validate_pos(pos: Vector2i) -> ValidPos:
	if pos.x < 0:
		return ValidPos.ZEROX
	if pos.y < 0:
		return ValidPos.ZEROY
	if pos.x > bounds.x:
		return ValidPos.BOUNDSX
	if pos.y > bounds.y:
		return ValidPos.BOUNDSY
	return ValidPos.VALID

func is_valid_door_position(tilemap: TileMap, position: Vector2i) -> bool:
	var is_valid = (
		# is the previous tile valid
		tilemap.get_cell_atlas_coords(0, Vector2i(position.x, position.y)) == TOP_WALL
		#is the current tile valid
		and tilemap.get_cell_atlas_coords(0, Vector2i(position.x-1, position.y)) == TOP_WALL
		#will the next tile be valid
		and tilemap.get_cell_atlas_coords(0, Vector2i(position.x+1, position.y)) == INVALID_CELL
		and is_walk_path(tilemap.get_cell_atlas_coords(0, Vector2i(position.x+1, position.y+1)))
	)
	#then we're good to go or not
	if is_valid:
		return true
	else:
		return false

func is_walk_path(tile: Vector2i):
	return tile == WALK_PATH or tile == WALK_PATH_ROT

func create_floor_tile(tilemap, position: Vector2i):
	var floor = WALK_PATH
	if randi()%4 == 0:
		floor = WALK_PATH_ROT
	tilemap.set_cell(0, Vector2i(position.x, position.y), 4, floor)
	floor_list.append(tilemap.to_global(tilemap.map_to_local(position)))

func get_player_position() -> Vector2:
	assert(door != null)
	var high_dist = 0
	var player_pos = null
	for pos in floor_list:
		var dist = (pos - door.position).length()
		#place sufficiently far away
		if dist > high_dist && dist - high_dist > 50:
			high_dist = dist
			player_pos = pos
	print("HELLO")
	return player_pos
