extends KinematicBody2D

var freeme = false
var random_pickup = 0
var startLoc = Vector2()
export var location1 = Vector2(6386, 1019)
var player = null

signal teleport(teleporting)


func _ready():
	randomize()
	random_pickup = randi() % 3
	var viewport_path = get_viewport().get_path()
	player = get_node(viewport_path as String + "/Player")
	connect("teleport", player, "_on_teleport_temp_teleport")
	player.connect("teleport_player", self , "_on_Player_interact")



func _on_Player_interact(collider_id):
	if collider_id == get_instance_id():
		emit_signal("teleport" , location1)
		print(location1)
		freeme = false



func _process(delta):
	if freeme:
		free()


func _on_Player_teleport_player():
	emit_signal("teleport" , location1)
	print(location1)



