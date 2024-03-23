extends Node2D

@onready var heart = preload("res://audio/sfx/heart.wav")
@onready var sfxplayer = preload("res://scenes/sfx_object.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.door_entered.connect(_on_door_entered)

func _on_door_entered():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("default")


func _on_area_2d_body_entered(body):
	if (body.has_method("heal")):
		body.heal(1)
		var new : AudioStreamPlayer = sfxplayer.instantiate()
		new.stream = heart
		_global.get_root_game().add_child.call_deferred(new)
		queue_free()
