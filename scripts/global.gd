extends Node
	


var viewport_container = null
var viewport = null


func get_root_game():
	return get_tree().root.get_node("/root/Game/SubViewportContainer/SubViewport/Node2D")

func _ready():
	EventBus.level_transition_over.emit()
