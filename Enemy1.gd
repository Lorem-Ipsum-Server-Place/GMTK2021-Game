extends KinematicBody2D

enum EnemyState {
	PERSUING,
	FLEEING
}

const MAX_OFFSET = 0.4
const MOVEMENT_SPEED = 50

var absolute_position = Vector2()
var vertical_velocity_modifier = 0
var tick_random_offset = 0
var player = null
var health = null
var dead = false
var state = EnemyState.PERSUING

var collision_layers = [3,2]


# Called when the node enters the scene tree for the first time.
func _ready():
	absolute_position = position
	tick_random_offset = rand_range(0, 1000)
	health = GameState.enemy_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# We don't want to error out if the player has died so allow for finding
	# a null reference
	if player == null:
		var viewport_path = get_viewport().get_path()
		player = get_node_or_null(viewport_path as String + "/Player")
		
	if dead:
		GameState.total_kills += 1
		free()

	
	
func _physics_process(delta):
	var time = OS.get_ticks_usec() / 100000
	
	vertical_velocity_modifier = sin(time + tick_random_offset) * MAX_OFFSET
	
	#position = absolute_position
	position.y += vertical_velocity_modifier
	
	if player != null and is_instance_valid(player):
		var movement_delta = player.position - position
		
		movement_delta = movement_delta.normalized() * MOVEMENT_SPEED
		
		if state == EnemyState.FLEEING:
			movement_delta *= -1
		
		$EnemyGraphic.flip_h = movement_delta.x > 0
		move_and_slide(movement_delta)
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if collision != null and collision.collider.name.find("Player"):
				#emit_signal("damage_player")
				pass

func take_damage(damage_value, collider_id):
	if collider_id == get_instance_id():
		for layer in collision_layers:
			set_collision_mask_bit(layer, 0)
		state = EnemyState.FLEEING
		$Timer.start()
		if health <= damage_value:
			dead = true
		else:
			health -= damage_value
		
		
		
	


func _on_Timer_timeout():
	for layer in collision_layers:
		set_collision_mask_bit(layer, 1)
	state = EnemyState.PERSUING
