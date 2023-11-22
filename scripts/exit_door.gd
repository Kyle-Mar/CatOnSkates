extends Sprite2D

signal door_entered
# Called when the node enters the scene tree for the first time.
var active = false
func _init():
	EventBus.level_transition_over.connect(start)

func _ready():
	pass

func start():
	active = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if not active:
		return
	if len(get_tree().get_nodes_in_group("enemies")) > 0:
		return
	if body in get_tree().get_nodes_in_group("player"):
		door_entered.emit()
		EventBus.door_entered.emit()
		active = false
		queue_free()
