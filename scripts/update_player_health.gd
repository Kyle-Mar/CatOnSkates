extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	PlayerInfo.max_health = get_parent().MAX_HEALTH
	PlayerInfo.health = get_parent().health
