extends Control

var hover_sound: AudioStreamPlayer
var click_sound: AudioStreamPlayer

func _ready():
	OS.window_fullscreen = true
	
	hover_sound = AudioStreamPlayer.new()
	hover_sound.stream = load("res://Assets/Audio/button-hover.wav")
	add_child(hover_sound)
	
	click_sound = AudioStreamPlayer.new()
	click_sound.stream = load("res://Assets/Audio/button-click.wav")
	add_child(click_sound)
	
	_connect_button_sounds($StartGame)
	_connect_button_sounds($Setting)
	_connect_button_sounds($Quit)

func _connect_button_sounds(button: Button):
	button.connect("mouse_entered", self, "_on_button_hover")
	button.connect("pressed", self, "_on_button_click")

func _on_button_hover():
	hover_sound.play()

func _on_button_click():
	click_sound.play()

func _on_StartGame_pressed():
	AudioManager.play_ambience()
	get_tree().change_scene("res://Main.tscn")

func _on_Setting_pressed():
	click_sound.play()
	get_tree().change_scene("res://Setting.tscn")

func _on_Quit_pressed():
	get_tree().quit()
