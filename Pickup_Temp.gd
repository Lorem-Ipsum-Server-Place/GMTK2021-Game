extends KinematicBody2D

const morejumps = 1
const speedboost = 50
var speed = 0
var freeme = false
var regenerate = 0
var random_pickup = 0



signal boostspeed(increase)
signal boostJumps(Jumping)


func _ready():
	randomize()
	random_pickup = randi() % 3
	


func _on_Player_collect_pickup():
	regenerate = 1
	if random_pickup == 2:
		emit_signal("boostspeed", speedboost )
	if random_pickup == 1:
		emit_signal("boostJumps", morejumps )
	print(random_pickup)
	freeme = true



func _process(delta):
	if regenerate == 1:
		randomize()
		random_pickup = randi() % 3
		regenerate = 0
		#print(regenerate)
		#print(random_pickup)
	if freeme:
		free()
