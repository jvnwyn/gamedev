extends Control

var hover_sound: AudioStreamPlayer
var click_sound: AudioStreamPlayer

onready var hallway = $Hallway
onready var presentation_room = $PresentationRoom
onready var faculty_room = $FacultyRoom
onready var fade_overlay = $FadeOverlay

var images = []
var current_index = 0
var slide_amount = 30.0
var is_transitioning = false

var fade_tween: Tween
var slide_tween: Tween

func _ready():
	OS.window_fullscreen = true
	
	hover_sound = AudioStreamPlayer.new()
	hover_sound.stream = load("res://Assets/Audio/button-hover.wav")
	add_child(hover_sound)
	
	click_sound = AudioStreamPlayer.new()
	click_sound.stream = load("res://Assets/Audio/button-click.wav")
	add_child(click_sound)
	
	fade_tween = Tween.new()
	add_child(fade_tween)
	slide_tween = Tween.new()
	add_child(slide_tween)
	
	_connect_button_sounds($StartGame)
	_connect_button_sounds($Quit)
	
	images = [hallway, presentation_room, faculty_room]
	
	for img in images:
		img.modulate = Color(1, 1, 1, 0)
		img.rect_position.x = 0
	
	fade_overlay.color = Color(0, 0, 0, 1)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_begin_show(0)

func _begin_show(index: int):
	current_index = index
	var img = images[index]
	img.modulate = Color(1, 1, 1, 1)
	img.rect_position.x = 0
	
	# Fade overlay out
	fade_tween.stop_all()
	fade_tween.interpolate_property(fade_overlay, "color:a",
		1.0, 0.0, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	fade_tween.start()
	
	# Slide image left
	slide_tween.stop_all()
	slide_tween.interpolate_property(img, "rect_position:x",
		0, -slide_amount, 6.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	slide_tween.start()
	
	# Timer to trigger next
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", self, "_begin_fadeout", [index, timer])
	timer.start()

func _begin_fadeout(index: int, timer: Timer):
	timer.queue_free()
	
	# Fade overlay in
	fade_tween.stop_all()
	fade_tween.interpolate_property(fade_overlay, "color:a",
		0.0, 1.0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	fade_tween.start()
	
	# Timer to show next image
	var next_timer = Timer.new()
	next_timer.wait_time = 1.0
	next_timer.one_shot = true
	add_child(next_timer)
	var next_index = (index + 1) % images.size()
	next_timer.connect("timeout", self, "_on_next_ready", [index, next_index, next_timer])
	next_timer.start()

func _on_next_ready(old_index: int, new_index: int, timer: Timer):
	timer.queue_free()
	images[old_index].modulate = Color(1, 1, 1, 0)
	images[old_index].rect_position.x = 0
	_begin_show(new_index)

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

func _on_Quit_pressed():
	get_tree().quit()
