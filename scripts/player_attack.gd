extends Node2D
@onready var bullet = preload("res://scenes/player_bullet.tscn")
@export var player_sprite:AnimatedSprite2D
@export var staff_sprite:AnimatedSprite2D

var is_firing = false

var nearby_enemies = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if not event is InputEventKey:
		return
		
	if event.keycode != Key.KEY_SPACE or not event.is_pressed() or event.is_echo():
		return
	
	var closest_enemy = null
	var closest_dist = INF
	for enemy in nearby_enemies:
		if(enemy.position - global_position).length() < closest_dist:
			closest_dist = (enemy.position - global_position).length()
			closest_enemy = enemy
			
			
	if closest_enemy:
		player_sprite.play("attack")
		staff_sprite.play("attack")
		look_at_enemy(global_position - closest_enemy.position)
		shoot_bullet(closest_enemy)


func look_at_enemy(vec_to_enemy):
	if -vec_to_enemy.x > 0 and not player_sprite.flip_h:
		player_sprite.flip_h = true
	if -vec_to_enemy.x < 0 and player_sprite.flip_h:
		player_sprite.flip_h = false	
	if -vec_to_enemy.x > 0 and not staff_sprite.flip_h:
		staff_sprite.flip_h = true
		staff_sprite.position.x *= -1
	if -vec_to_enemy.x < 0 and staff_sprite.flip_h:
		staff_sprite.flip_h = false	
		staff_sprite.position.x *= -1

func shoot_bullet(target):
	if is_firing:
		return
	is_firing = true
	var _bullet = bullet.instantiate()
	_bullet.position = global_position
	_global.get_root_game().add_child.call_deferred(_bullet)
	_bullet.transform = _bullet.transform.looking_at(target.global_position)


func _on_fire_zone_body_entered(body):
	nearby_enemies.append(body)	

func _on_fire_zone_body_exited(body):
	if body in nearby_enemies:
		nearby_enemies.erase(body)


func _on_staff_animation_looped():
	is_firing = false
	print("done_firing")
	staff_sprite.pause()
