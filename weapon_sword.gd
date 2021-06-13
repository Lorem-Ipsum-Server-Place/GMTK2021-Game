extends KinematicBody2D

enum WeaponState {
	IDLE,
	ATTACKING
}

# by default the sword is inactive
var current_damage = 0
var state = WeaponState.IDLE

var collision_layers = [2]

signal deal_damage(damage_value, instance)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if state == WeaponState.ATTACKING:
		var my_position = self.position
		
		# move_and_slide to get colliders, but we don't want to actually translate
		# the weapon so we reset it's position right after
		move_and_slide(Vector2())
		
		self.position = my_position
		
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			print("hit an enemy!")
			emit_signal("deal_damage", current_damage, collision.collider_id)

func set_collisions(value: bool):
	for layer in collision_layers:
		set_collision_layer_bit(layer, value)
		set_collision_mask_bit(layer, value)

func _on_Player_set_weapon_damage(new_damage_value):
	if new_damage_value == 0:
		state = WeaponState.IDLE
		current_damage = 0
		set_collisions(0)
	else:
		state = WeaponState.ATTACKING
		current_damage = new_damage_value
		set_collisions(1)
