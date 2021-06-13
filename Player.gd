extends KinematicBody2D

enum PlayerDirection{
	RIGHT,
	LEFT
}

enum PlayerAttackState{
	READY,
	ACTIVE,
	NOT_READY
}

var startingloc = Vector2()
var location1 = Vector2(6386, 1019)
var player_velocity = Vector2()
var jump_count = 1
var player_weapon = null
var player_direction = PlayerDirection.RIGHT
var is_invincible = false
var PLAYER_MOVE_SPEED = INITIAL_PLAYER_MOVE_SPEED
var PLAYER_JUMP_COUNT = INITIAL_PLAYER_JUMP_COUNT
var dead = false
var attack_state = PlayerAttackState.READY
var attack_angle = 0
var attack_starting_pos = Vector2()


const INITIAL_PLAYER_MOVE_SPEED = 600
const PLAYER_JUMP_VELOCITY = 1200
const INITIAL_PLAYER_JUMP_COUNT = 2

const PLAYER_WEAPON_ATTACK_RANGE = 160

const PLAYER_WEAPON_VERTICAL_OFFSET = 60
const PLAYER_WEAPON_MAX_HORIZONTAL_OFFSET = 80

const PLAYER_WEAPON_DAMAGE = 5
const PLAYER_WEAPON_RECALL_DISTANCE = 1 #px
const PLAYER_WEAPON_MAX_RESET_DEVIANCE = 40 #px

const PLAYER_WEAPON_IDLE_LERP_WEIGHT = 0.05
const PLAYER_WEAPON_ROTATION_LERP_WEIGHT = 0.25
const PLAYER_WEAPON_ATTACK_LERP_WEIGHT = 0.4
const PLAYER_WEAPON_RETURN_LERP_WEIGHT = 0.35

const INVINCIBILITY_DURATION_SECONDS = 1
const ENEMY_COLLISION_LAYERS = [3]

const GRAVITY = 60
signal teleport_player(collider_id)
signal damage_player()
signal collect_pickup()
# pass damage value so we can set it to 0 if we're not mid-attack
signal weapon_set_damage(damage_value)

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
	
	connect("damage_player", self, "_on_Player_damage_player")
	connect("weapon_set_damage", player_weapon, "_on_Player_set_weapon_damage")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		get_tree().change_scene("res://Levels/Menu/Game Over.tscn")
		self.free()
	else:
		var new_modulate_colour = lerp(
			$"Player Debug Sprite".modulate,
			Color(1,1,1),
			0.05
		)
		
		$"Player Debug Sprite".modulate = new_modulate_colour


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
		
	if attack_state == PlayerAttackState.READY and Input.is_action_just_pressed("game_attack"):
		attack_state = PlayerAttackState.ACTIVE
		attack_angle = player_weapon.rotation
		attack_starting_pos = player_weapon.position
		emit_signal("weapon_set_damage", PLAYER_WEAPON_DAMAGE)
		
	
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


func is_collider_pickup(collision: KinematicCollision2D):
	var colliding_object_class = collision.collider.name
	
	# Assume that all Pickups will have Pickup in their KinematicBody2D name
	if colliding_object_class.find("Pickup") != -1:
		print("Pickup!")
		return true
	return false


func is_collider_teleport(collision: KinematicCollision2D):
	var colliding_object_class = collision.collider.name
	
	# Assume that all Pickups will have Teleport in their KinematicBody2D name
	if colliding_object_class.find("teleport") != -1:
		print("teleport")
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
			emit_signal("damage_player")
		elif is_collider_pickup(collision):
			emit_signal("collect_pickup")
		elif is_collider_teleport(collision):
			emit_signal("teleport_player", collision.collider_id)
			
	
	# Ask the collision whether we're stood on something
	if jump_count != PLAYER_JUMP_COUNT and is_on_floor():
		jump_count = PLAYER_JUMP_COUNT


func set_enemy_collisions(collisions_on: bool):
	for layer in ENEMY_COLLISION_LAYERS:
		set_collision_layer_bit(layer, collisions_on)
		set_collision_mask_bit(layer, collisions_on)

func _on_InvincibilityTimer_timeout():
	# The timer has told us that our invincibility ran out
	is_invincible = false
	set_enemy_collisions(true)


func _on_GameState_player_dead():
	# The gamestate has told us that our health has hit zero. We'll still be 
	# in the physics processing so just set a flag saying that we're dead so
	# we can clean ourselves up in the process() phase where it's safe to do so
	dead = true

func _on_Player_damage_player():
	# start our timer for our invincibility frames
	$InvincibilityTimer.start(INVINCIBILITY_DURATION_SECONDS)
	is_invincible = true
	set_enemy_collisions(false)
	
	var damage_colour = Color(1,.5,.5,1)
	$"Player Debug Sprite".modulate = damage_colour
	

func on_GameState_rotate_sword(rotation):
	if attack_state in [PlayerAttackState.READY, PlayerAttackState.NOT_READY]:
		# fully rotate weapon to avoid strange lerp behaviour when 
		# the sign flips
		if Input.is_action_just_pressed("ui_accept"):
			print("Rotation: ", rotation)
			print("Weapon Rotation: ", player_weapon.rotation)
		
		if rotation > PI and player_weapon.rotation < -PI / 4:
			player_weapon.rotation += 2 * PI
			print("New Weapon Rotation: ", player_weapon.rotation)
		elif rotation < -PI/4  and player_weapon.rotation > PI:
			player_weapon.rotation -= 2 * PI
			print("New Weapon Rotation: ", player_weapon.rotation)
		# Set our weapon rotation to what's set in the game state
		var new_rotation = lerp(
			player_weapon.rotation,
			rotation,
			PLAYER_WEAPON_ROTATION_LERP_WEIGHT
		)
		
		player_weapon.rotation = new_rotation
		
		var horizontal_offset = sin(rotation)
		var desired_position = Vector2(
			-horizontal_offset * PLAYER_WEAPON_MAX_HORIZONTAL_OFFSET,
			-PLAYER_WEAPON_VERTICAL_OFFSET
		)
		
		var lerp_weight = PLAYER_WEAPON_IDLE_LERP_WEIGHT
		if attack_state == PlayerAttackState.NOT_READY:
			lerp_weight = PLAYER_WEAPON_RETURN_LERP_WEIGHT
		
		var new_position = lerp(
			player_weapon.position,
			desired_position,
			lerp_weight
		)
		
		player_weapon.position = new_position
		
		if attack_state == PlayerAttackState.NOT_READY:
			var position_delta = desired_position - new_position
			if position_delta.length() <= PLAYER_WEAPON_MAX_RESET_DEVIANCE:
				attack_state = PlayerAttackState.READY
		
		
	else:
		# we're attacking, so jab forwards. probably not gonna be adding guns...
		var desired_position = Vector2(
			sin(attack_angle),
			-cos(attack_angle)
		) * PLAYER_WEAPON_ATTACK_RANGE 
		
		desired_position += attack_starting_pos
		
		var new_position = lerp(
			player_weapon.position,
			desired_position,
			PLAYER_WEAPON_ATTACK_LERP_WEIGHT
		)
		
		player_weapon.position = new_position
		
		var position_delta = new_position - desired_position
		
		if position_delta.length() <= PLAYER_WEAPON_RECALL_DISTANCE:
			attack_state = PlayerAttackState.NOT_READY
			emit_signal("weapon_set_damage", 0)

func _on_Pickup_Temp_boostspeed(increase):
	PLAYER_MOVE_SPEED += increase
	print("Boosting Speed")


func _on_Pickup_Temp_boostJumps(Jumping):
	PLAYER_JUMP_COUNT += Jumping
	print("Boosting Jumps")


func _on_teleport_temp_teleport(teleporting):
	startingloc = get_global_position()
	set_global_position(location1)
	
