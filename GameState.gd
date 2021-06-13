extends Node2D

var player_health = 4
var weapon_rotation = 0
var enemy_health = 10

var total_kills = 0

var viewport_count = 1


signal player_dead()
signal weapon_rotation(angle)

func damage_player():
	player_health -= 1
	print("Ouch")
	if player_health == 0:
		# we've hit zero health so notify anyone who cares
		emit_signal("player_dead")
		


func _on_Player_damage_player():
	# the player has colllided with an enemy
	damage_player()

func _ready():
	pass



func _process(delta):
	emit_signal("weapon_rotation", weapon_rotation)

func _on_Theatre_update_global_weapon_angle(rotation):
	weapon_rotation = rotation
