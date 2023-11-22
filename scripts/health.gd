extends CollisionShape2D
@export var MAX_HEALTH:int
@export var health:int
# Called when the node enters the scene tree for the first time.

func damage(amount):
	health -= amount
	health = max(health, 0)
	print(health)
	if(health <= 0):
		get_node("Death").die(get_parent())
		#$Death.die(get_parent())
	
func heal(amount):
	health += amount
	health = min(health, MAX_HEALTH)
