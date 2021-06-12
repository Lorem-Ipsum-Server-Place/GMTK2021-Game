extends Node2D

var player_health = 4


signal player_dead()


func damage_player():
	player_health -= 1
	print("Ouch")
	if player_health == 0:
		# we've hit zero health so notify anyone who cares
		emit_signal("player_dead")


func _on_Player_damage_player():
	# the player has colllided with an enemy
	damage_player()
