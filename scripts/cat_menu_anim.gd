extends TextureRect

const speed = 1000
@export var left:float
@export var right:float
var dir:Vector2 = Vector2.LEFT

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	print(global_position)
	
	if global_position.x < left:
		dir = Vector2.RIGHT
		flip_h = not flip_h
	if global_position.x > right:
		dir = Vector2.LEFT
		flip_h = not flip_h
	
	
	position += dir * delta * speed
