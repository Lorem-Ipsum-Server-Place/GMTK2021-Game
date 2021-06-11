extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player_velocity = Vector2()
var jump_count = 1

const PLAYER_MOVE_SPEED = 450
const PLAYER_JUMP_VELOCITY = 1000

const GRAVITY = 60


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_inputs():
	if Input.is_action_pressed("game_left") or Input.is_action_pressed("game_right"):
		if Input.is_action_pressed("game_left") and not Input.is_action_pressed("game_right"):
			player_velocity.x = -PLAYER_MOVE_SPEED
		elif Input.is_action_pressed("game_right") and not Input.is_action_pressed("game_left"):
			player_velocity.x = PLAYER_MOVE_SPEED
	else:
		player_velocity.x = 0
	
	if Input.is_action_just_pressed("game_jump") and jump_count > 0:
		player_velocity.y = -PLAYER_JUMP_VELOCITY
		#jump_count -= 1

	player_velocity.y += GRAVITY


func _physics_process(delta):
	get_inputs()
	
	player_velocity = move_and_slide(player_velocity)
	
