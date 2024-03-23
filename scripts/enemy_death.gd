extends Node
@onready var heart = preload("res://scenes/heart.tscn")
@onready var death = preload("res://audio/sfx/enemy_death.wav")
@onready var sfx = preload("res://scenes/sfx_object.tscn")


func die(obj):
	var inst = heart.instantiate()
	inst.position = get_parent().get_parent().global_position
	_global.get_root_game().add_child.call_deferred(inst)
	
	var new = sfx.instantiate()
	new.stream = death
	_global.get_root_game().add_child.call_deferred(new)
	
	obj.queue_free()
