extends Node2D


var SPEED = 100.0

func _ready():
	pass
	#look_at(PlayerInfo.position)

func _process(delta):
	position += transform.x * SPEED * delta


func _on_area_2d_body_entered(body):
	if not body.has_method("damage"):
		queue_free()
		return
	body.damage(1, body.position - position)
	
	queue_free()
