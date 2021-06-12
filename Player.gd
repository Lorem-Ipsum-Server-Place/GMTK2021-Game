extends KinematicBody2D

enum PlayerDirection{
	RIGHT,
	LEFT
}

var player_velocity = Vector2()
var jump_count = 1
var player_weapon = null
var player_direction = PlayerDirection.RIGHT
var is_invincible = false


var dead = false


const PLAYER_MOVE_SPEED = 450
const PLAYER_JUMP_VELOCITY = 1000
const PLAYER_JUMP_COUNT = 2
const PLAYER_WEAPON_DISTANCE = 40
const INVINCIBILITY_DURATION_SECONDS = 1

const GRAVITY = 60

signal damage_player()

# Load weapon scenes, we can choose from these on init
onready var WEAPON_SWORD = load("res://weapon_sword.tscn")
onready var WEAPON_BLAH = null
var game_state = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Dynamically add the weapon on init so we can use a different weapon if we 
	# want to
	player_weapon = WEAPON_SWORD.instance()
	add_child(player_weapon, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	
	# position weapon in line with cursor relative to the character
	var sword_position = (mouse_position - position).normalized() * PLAYER_WEAPON_DISTANCE
	player_weapon.position = sword_position
	
	# work out hte angle to point the sword away based on our position delta
	var weapon_rotation = atan(sword_position.x / -sword_position.y)
	# correct the angle if the sword points down
	if sword_position.y > 0:
		weapon_rotation += PI
	
	player_weapon.rotation = weapon_rotation
	
	# We died during the physics processing, delete ourselves
	if dead:
		self.free()

func get_inputs():
	# If either direction is pressed, figure out which way we're going
	if Input.is_action_pressed("game_left") or Input.is_action_pressed("game_right"):
		if Input.is_action_pressed("game_left") and not Input.is_action_pressed("game_right"):
			player_velocity.x = -PLAYER_MOVE_SPEED
		elif Input.is_action_pressed("game_right") and not Input.is_action_pressed("game_left"):
			player_velocity.x = PLAYER_MOVE_SPEED
	# otherwise cancel our movement
	else:
		player_velocity.x = 0
	
	# If we have any jumps left, set our vertical jump velocity so we go up
	if Input.is_action_just_pressed("game_jump") and jump_count > 0:
		player_velocity.y = -PLAYER_JUMP_VELOCITY
		jump_count -= 1

	player_velocity.y += GRAVITY


func is_collider_enemy(collision: KinematicCollision2D):
	var colliding_object_class = collision.collider.name
	
	# Assume that all enemies will have Enemy in their KinematicBody2D name
	if colliding_object_class.find("Enemy") != -1:
		return true
	return false

func _physics_process(delta):
	get_inputs()
	
	var player_vertical_speed = player_velocity.y
	
	player_velocity = move_and_slide(player_velocity, Vector2(0,-1))
	
	var collision_count = get_slide_count()
	
	# Check to see if any of the collisions were with an enemy. Tell the game 
	# state to damage us if they were.
	for i in range(collision_count):
		var collision = get_slide_collision(i)
		if not is_invincible and  is_collider_enemy(collision):
			# start our timer for our invincibility frames
			$InvincibilityTimer.start(INVINCIBILITY_DURATION_SECONDS)
			is_invincible = true
			emit_signal("damage_player")
	
	# Ask the collision whether we're stood on something
	if jump_count != PLAYER_JUMP_COUNT and is_on_floor():
		jump_count = PLAYER_JUMP_COUNT


func _on_InvincibilityTimer_timeout():
	# The timer has told us that our invincibility ran out
	is_invincible = false


func _on_GameState_player_dead():
	# The gamestate has told us that our health has hit zero. We'll still be 
	# in the physics processing so just set a flag saying that we're dead so
	# we can clean ourselves up in the process() phase where it's safe to do so
	dead = true
