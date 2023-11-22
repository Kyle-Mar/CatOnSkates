extends CharacterBody2D

var touching_player = false
@onready var fire_point = $FirePoint
@onready var BULLET = preload("res://scenes/enemy_bullet.tscn")

var prev_velocity = Vector2.ZERO
var prev_collision:KinematicCollision2D = null

var is_kb = false
var kb_direction = Vector2.ZERO

const SPEED = 50

func _process(delta):
	if is_kb:
		velocity = kb_direction.normalized() * SPEED * 2 * delta
		var collision = move_and_collide(velocity)
		if(collision):
			is_kb = false
		
func move_to(pos, delta):
	
	if is_kb:
		return
	
	var init_vel = velocity
	if (PlayerInfo.position - position).length() < 300:
		$RayCast2D.target_position = to_local(PlayerInfo.position) - $RayCast2D.position 
		
		if($FireTimer.is_stopped()):
			$FireTimer.start()
		
		####move to target###
		velocity = (pos-global_position).normalized() * SPEED * delta
		
		#####if too close run away!#####
		if 45 > (PlayerInfo.position - position).length() && (PlayerInfo.position - position).length() >= 0 and not $RayCast2D.is_colliding():
			velocity = lerp(init_vel, -(PlayerInfo.position - position).normalized() * SPEED * delta, 0.25)

		#####if close enough stop#####
		elif(PlayerInfo.position - position).length() < 50 and not $RayCast2D.is_colliding():
			velocity = lerp(init_vel, Vector2.ZERO, 0.25)
			
		######collision on corner fixer######
		var collision = move_and_collide(velocity)
		if(collision):
			#if $RayCast2D.is_colliding():
			$CollisionTimer.start(0.1)
			prev_collision = collision
		if not $CollisionTimer.is_stopped():
			velocity = Vector2(-prev_collision.get_normal().y, -prev_collision.get_normal().x) * SPEED * delta 
		
		### look towards player ###
		if -(PlayerInfo.position - position).x > 0 and not $Sprite2D.flip_h:
			$Sprite2D.flip_h = true
		if -(PlayerInfo.position - position).x < 0 and $Sprite2D.flip_h:
			$Sprite2D.flip_h = false	
	else:
		$FireTimer.stop()
	
func damage(amt, kb_dir):
	if($KBTimer.is_stopped()):
		$KBTimer.start()
		is_kb = true
		kb_direction = kb_dir
		print(kb_direction)
	$Health.damage(amt)
	

func _on_area_2d_body_entered(body):
	pass


func _on_fire_timer_timeout():
	var bullet = BULLET.instantiate()
	bullet.position = fire_point.global_position
	bullet.SPEED += velocity.length()
	bullet.transform = bullet.transform.looking_at(PlayerInfo.global_position)
	add_sibling.call_deferred(bullet)


func _on_kb_timer_timeout():
	is_kb = false
