extends Control

func _ready():
	OS.window_fullscreen = true
	
func _on_StartGame_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_Settings_pressed():
	pass # Add settings logic later

func _on_Quit_pressed():
	get_tree().quit()


func _on_Setting_pressed():
	pass # Replace with function body.
