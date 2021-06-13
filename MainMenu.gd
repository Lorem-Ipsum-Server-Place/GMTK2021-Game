extends Control

func _ready():
	$VBoxContainer/Start.grab_focus()
	

func _on_Start_pressed():
	get_tree().change_scene("res://Levels/MainGame/Theatre.tscn")











#OBSOLETE CODE (Will get rid of it later if cant implement properly)
#onready var selector_one = $CenterContainer/VBoxContainer/CenterContainer2/CenterContainer3/VBoxContainer2/CenterContainer/HBoxContainer/Selector
#onready var selector_two = $CenterContainer/VBoxContainer/CenterContainer2/CenterContainer3/VBoxContainer2/CenterContainer/HBoxContainer/Selector
#onready var selector_three = $CenterContainer/VBoxContainer/CenterContainer2/CenterContainer3/CenterContainer4/VBoxContainer/CenterContainer/HBoxContainer/Selector
#var current_selection = 0

#func _ready():
	#set_current_selection(0)
	
#func _process(delta):
#	if Input.is_action_just_pressed("ui_down"):
	#current_selection +=1
	#set_current_selection(current_selection)
	

#func set_current_selection(_current_selection):
#	selector_one.text = ""
#	selector_two.text = ""
#	selector_three.text = ""
#	if _current_selection ==0:
#		selector_one.text = ">"
#	elif _current_selection ==1:
#		selector_one.text = ">"
#	elif _current_selection ==2:
#		selector_one.text = ">"




#func _on_Start_pressed():
#	pass # Replace with function body.


func _on_Options_pressed():
	var options = load("res://Levels/Menu/Controls.tscn").instance()
	get_tree().current_scene.add_child(options)


func _on_Quit_pressed():
	get_tree().quit()
