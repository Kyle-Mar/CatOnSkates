extends Node2D
var EnemyScene : PackedScene
@export var num_enemies:int = 3
var floor_list : Array[Vector2]

func _init():
	EnemyScene = preload("res://scenes/enemy.tscn")
	EventBus.player_position_picked.connect(_on_player_position_picked)
	EventBus.floor_list_done.connect(_on_floor_list_done)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_floor_list_done(floor_list):
	self.floor_list = floor_list

func spawn_enemies():
	if floor_list.size() <= 0:
		return
	for i in range(num_enemies):	
		var new = EnemyScene.instantiate()
		new.global_position = floor_list.pop_at(randi_range(0, floor_list.size()))
		_global.get_root_game().add_child.call_deferred(new)
	num_enemies+=1

func _on_player_position_picked(player_position):
	var new = EnemyScene.instantiate()
	var future_list:Array[Vector2] = []
	for pos in floor_list:
		if pos.distance_to(player_position) < 100:
			continue
		else:
			future_list.append(pos)
	floor_list = future_list
	spawn_enemies()
	
	
