extends Control

func _ready():
	pass
	

func _on_Start_pressed():
	get_tree().change_scene("res://Levels/Menu/Difficulty.tscn")


func _on_Quit_pressed():
	get_tree().quit()


func _on_Normal_pressed():
	GameState.viewport_count = 2
	get_tree().change_scene("res://Levels/MainGame/Theatre.tscn")


func _on_Hard_pressed():
	GameState.viewport_count = 4
	get_tree().change_scene("res://Levels/MainGame/Theatre.tscn")


func _on_Impossible_pressed():
	GameState.viewport_count = 9
	get_tree().change_scene("res://Levels/MainGame/Theatre.tscn")
