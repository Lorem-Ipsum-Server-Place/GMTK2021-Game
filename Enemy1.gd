extends KinematicBody2D


const MAX_OFFSET = 0.4
const MOVEMENT_SPEED = 1

var absolute_position = Vector2()
var vertical_velocity_modifier = 0
var tick_random_offset = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	absolute_position = position
	tick_random_offset = rand_range(0, 1000)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time = OS.get_ticks_usec() / 100000
	
	vertical_velocity_modifier = sin(time + tick_random_offset) * MAX_OFFSET
	print(time)
	
	#position = absolute_position
	position.y += vertical_velocity_modifier
	
	var player = get_node("/root/Node2D/Player")
	
	var movement_delta = player.position - position
	
	movement_delta = movement_delta.normalized() * MOVEMENT_SPEED
	move_and_collide(movement_delta)
	
	
