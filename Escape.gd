extends Control

onready var color_rect = $ColorRect
onready var tween = $Tween
onready var title = $Escape
onready var button = $BackToMenu

var hover_sound: AudioStreamPlayer
var click_sound: AudioStreamPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	title.modulate = Color(1, 1, 1, 0)
	button.modulate = Color(1, 1, 1, 0)
	color_rect.color = Color(0, 0, 0, 0)

	hover_sound = AudioStreamPlayer.new()
	hover_sound.stream = load("res://Assets/Audio/button-hover.wav")
	add_child(hover_sound)

	click_sound = AudioStreamPlayer.new()
	click_sound.stream = load("res://Assets/Audio/button-click.wav")
	add_child(click_sound)

	button.connect("mouse_entered", self, "_on_button_hover")
	button.connect("pressed", self, "_on_button_click")

	AudioManager.stop_ambience()
	AudioManager.stop_hunt()

	var player = get_tree().get_root().find_node("Player", true, false)
	if player and player.has_method("fade_out_hud"):
		player.fade_out_hud()

	yield(get_tree().create_timer(0.5), "timeout")

	tween.interpolate_property(
		color_rect, "color",
		Color(0, 0, 0, 0), Color(0, 0, 0, 1),
		2.5, Tween.TRANS_SINE, Tween.EASE_IN
	)
	tween.start()
	tween.connect("tween_all_completed", self, "_on_blackout_done")

func _on_button_hover():
	hover_sound.play()

func _on_button_click():
	click_sound.play()

func _on_blackout_done():
	tween.disconnect("tween_all_completed", self, "_on_blackout_done")
	tween.interpolate_property(
		title, "modulate",
		Color(1, 1, 1, 0), Color(1, 1, 1, 1),
		1.5, Tween.TRANS_SINE, Tween.EASE_IN
	)
	tween.start()
	tween.connect("tween_all_completed", self, "_on_title_done")

func _on_title_done():
	tween.disconnect("tween_all_completed", self, "_on_title_done")
	tween.interpolate_property(
		button, "modulate",
		Color(1, 1, 1, 0), Color(1, 1, 1, 1),
		1.0, Tween.TRANS_SINE, Tween.EASE_IN
	)
	tween.start()

func _on_BackToMenu_pressed():
	get_tree().paused = false
	call_deferred("_go_to_menu")

func _go_to_menu():
	AudioManager.stop_ambience()
	get_parent().get_parent().queue_free()
	get_tree().change_scene("res://MainMenu.tscn")
