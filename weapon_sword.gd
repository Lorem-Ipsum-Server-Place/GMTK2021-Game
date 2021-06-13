extends KinematicBody2D

enum WeaponState {
	IDLE,
	ATTACKING
}

# by default the sword is inactive
var current_damage = 0
var state = WeaponState.IDLE

signal deal_damage(damage_value, instance)

# Called when the node enters the scene tree for the first time.
func _ready():
	if state == WeaponState.ATTACKING:
		var my_position = self.position
		
		# move_and_slide to get colliders, but we don't want to actually translate
		# the weapon so we reset it's position right after
		move_and_slide(Vector2())
		
		self.position = my_position
		
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			emit_signal("deal_damage", current_damage, collision.collider_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Player_set_weapon_damage(new_damage_value):
	if new_damage_value == 0:
		state = WeaponState.IDLE
		current_damage = 0
	else:
		state = WeaponState.ATTACKING
		current_damage = new_damage_value
