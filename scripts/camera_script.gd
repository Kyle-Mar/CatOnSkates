extends Camera2D

@export var player: Node

@onready var game_size := Vector2(80, 45)
@onready var window_scale := (Vector2(get_window().size) / game_size).x

@onready var actual_cam_pos := global_position

func _ready():
	pass


func _process(delta):
	# First we get the "real" position of the mouse cursor and then the offset to the player
	# To do that, we need to divide the mouse position inside the local viewport by the game window scale
	# Then substract half of the game size and add the player position
	#var mouse_pos = DisplayServer.mouse_get_position() - get_window().position
	#mouse_pos = mouse_pos / window_scale - (game_size/2) + player.global_position

	# Using a lerp, the cameras position is moved towards the mouse position
	#var cam_pos = lerp( player.global_position, player.global_position + player.velocity, 0.7)
	var cam_pos = player.global_position
	# Use another lerp to make the movement smooth
	actual_cam_pos = lerp(actual_cam_pos, cam_pos, 5*delta)

	# Calculate the "subpixel" position of the new camera position
	var cam_subpixel_pos = actual_cam_pos.round() - actual_cam_pos

	# Update the Main ViewportContainer's shader uniform
	_global.viewport_container.material.set_shader_parameter("cam_offset", cam_subpixel_pos )

	# Set the camera's position to the new position and round it.
	global_position = actual_cam_pos.round()
	align()
