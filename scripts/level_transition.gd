extends Sprite2D
var scale_up = true
var picked_queued = false
var entered_door = false

@onready var door_sfx = preload("res://audio/sfx/door.wav")
@onready var sfxplayer = preload("res://scenes/sfx_object.tscn")

func _init():
	EventBus.door_entered.connect(_on_door_entered)
	EventBus.player_position_picked.connect(_on_player_position_picked)

func _on_player_position_picked(_pos):

	picked_queued = true
	scale_up = false
func _on_door_entered():
	var new : AudioStreamPlayer = sfxplayer.instantiate()
	new.stream = door_sfx
	_global.get_root_game().add_child.call_deferred(new)
	scale = Vector2(1000,1000)
	entered_door = true
	scale_up = true
	#scale = Vector2(0.01, 0.01)
	

func _process(delta):
	if scale_up or not picked_queued:
		if not entered_door:
			return
		if(scale.x < 1000):

			apply_scale(Vector2(1.4, 1.4))
		else:
			EventBus.level_transition_over.emit()
			scale_up = false
	else:
		if scale.x < 0.01 and picked_queued:
			EventBus.level_transition_over.emit()

			entered_door = false
			picked_queued = false
		apply_scale(Vector2(0.6, 0.6))
		rotate(deg_to_rad(10))

