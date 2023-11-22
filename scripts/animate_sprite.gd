extends Sprite2D
@onready var idle = preload("res://sprites/wizard-cat-idle.png")
@onready var run = preload("res://sprites/wizard_cat-Sheet.png")
@onready var kb = preload("res://sprites/wizard-cat-kb.png")

signal on_idle
signal on_run
signal on_kb

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if texture == kb:
		hframes = 1
	else:
		hframes = 2
	get_groups()
func _on_animation_timer_timeout():
	frame = (frame+1) % (vframes*hframes)


func _on_on_idle():
	if texture != idle:
		$AnimationTimer.start(1)
		texture = idle


func _on_on_run():
	if texture != run:
		$AnimationTimer.start(.1)
		texture = run


func _on_on_kb():
	if texture != kb:
		frame = 0
		texture = kb
