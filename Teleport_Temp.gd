extends KinematicBody2D

var freeme = false
var random_pickup = 0
var startLoc = Vector2()
var location1 = Vector2(1433, -132)


signal teleport(teleporting)


func _ready():
	randomize()
	random_pickup = randi() % 3
	


func _on_Player_interact():
	emit_signal("teleport" , location1)
	print(location1)
	freeme = false



func _process(delta):
	if freeme:
		free()


func _on_Player_teleport_player():
	emit_signal("teleport" , location1)
	print(location1)
