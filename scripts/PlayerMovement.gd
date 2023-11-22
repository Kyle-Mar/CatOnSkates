extends CharacterBody2D
var speed = 100
var move_vec = Vector2(0,0);
var input_positions = []
#@onready var text = $Camera2D/SpeedText
@onready var swipe_timer = $SwipeTimer
@onready var KBTimer = $KBTimer
@onready var HurtBox = $HurtBox

var box: PackedScene = preload("res://scenes/box.tscn")

var is_kb = false
var kb_direction = Vector2.ZERO
var next_init_player_position = null
var can_move = 2

# Called when the node enters the scene tree for the first time.
func _init():
	EventBus.player_position_picked.connect(_on_position_picked)
	EventBus.level_transition_over.connect(_on_level_transition_over)
	EventBus.door_entered.connect(_on_door_entered)
	EventBus.level_transition_over.connect(_on_level_transition)

func _ready():
	PlayerInfo.position = position
	PlayerInfo.global_position = global_position
	
	pass # Replace with function body.

func _on_door_entered():
	can_move = 2

func _on_level_transition():
	can_move -= 1

func _on_level_transition_over():
	print("GOOBLE", next_init_player_position)
	if(next_init_player_position):
		global_position = next_init_player_position

func _on_position_picked(pos):
	if(next_init_player_position == null):
		global_position = pos
	next_init_player_position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	if can_move > 0:
		return
	if(velocity.length() > 0 and not $Staff/PlayerFire.is_firing):
		$PlayerSprite.play("run")
		$PlayerSprite.speed_scale = 2
	elif(not $Staff/PlayerFire.is_firing):
		$PlayerSprite.play("idle")
		$PlayerSprite.speed_scale = 1	
	if is_kb:
		$PlayerSprite.play("kb")
		if(not $Staff/PlayerFire.is_firing):
			flip_sprite_kb()
		velocity = kb_direction.normalized() * speed * 2
	else:
		if(not $Staff/PlayerFire.is_firing):
			flip_sprite()
		velocity = move_vec * speed
	
	move_and_slide()
	PlayerInfo.position = position
	#print(global_position)
	pass

func flip_sprite():
	if velocity.x > 0 and not $PlayerSprite.flip_h:
		$PlayerSprite.flip_h = true
		$Staff.flip_h = true
		$Staff.position.x *= -1
	if velocity.x < 0 and $PlayerSprite.flip_h:
		$PlayerSprite.flip_h = false
		$Staff.flip_h = false
		$Staff.position.x *= -1

func flip_sprite_kb():
	if -kb_direction.x > 0 and not $PlayerSprite.flip_h:
		$PlayerSprite.flip_h = true
		$Staff.flip_h = true
		$Staff.position.x *= -1
	if -kb_direction.x < 0 and $PlayerSprite.flip_h:
		$PlayerSprite.flip_h = false
		$Staff.flip_h = false
		$Staff.position.x *= -1

func damage(amount, direction):
	if(KBTimer.is_stopped()):
		KBTimer.start()
		kb_direction = direction
		is_kb = true
	$HurtBox.damage(amount)

func _input(event):
	if event is InputEventScreenDrag:
		if(swipe_timer):
			swipe_timer.start()
		#text.text = str(event.position)
		input_positions.append(event.position)
	if event is InputEventMouseMotion:
		print("HELLO")
		if(swipe_timer):
			swipe_timer.start()
		#text.text = str(event.position)
		input_positions.append(event.position)
	elif event is InputEventKey:

		var movx = Input.get_axis("neg_mov_x","pos_mov_x")	
		var movy = Input.get_axis("pos_mov_y","neg_mov_y")
		#if movx == 0 and movy ==0:
		#	return
		move_vec = Vector2(movx, movy)
		move_vec = move_vec.normalized()

func _on_timer_timeout():
	if(len(input_positions) <2):
		return
	var rel = (input_positions[-1] - input_positions[0]).normalized()
	if abs(rel.x) >= abs(rel.y):
		move_vec = Vector2(1 * sign(rel.x),0)
	elif abs(rel.x) < abs(rel.y):
		move_vec = Vector2(0, 1 * sign(rel.y))
	
	input_positions.clear()

func _on_kb_timer_timeout():
	is_kb = false
