extends Control

onready var master_slider = $VBoxContainer/audio_master/MasterSlider
onready var sensitivity_slider = $VBoxContainer/sensitivity/SensitivitySlider
onready var fullscreen_toggle = $FullscreenToggle
onready var back_button = $Button
onready var tween = $Tween

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

	master_slider.min_value = 0
	master_slider.max_value = 1
	master_slider.step = 0.01
	master_slider.value = 1.0

	sensitivity_slider.min_value = 0.1
	sensitivity_slider.max_value = 2.0
	sensitivity_slider.step = 0.01
	sensitivity_slider.value = 0.5

	fullscreen_toggle.pressed = OS.window_fullscreen

	master_slider.connect("value_changed", self, "_on_master_changed")
	sensitivity_slider.connect("value_changed", self, "_on_sensitivity_changed")
	fullscreen_toggle.connect("toggled", self, "_on_fullscreen_toggled")
	back_button.connect("pressed", self, "_on_back_pressed")
	back_button.connect("mouse_entered", self, "_on_button_hover")

	var font = DynamicFont.new()
	font.font_data = load("res://Assets/ui/Cinzel/Cinzel-VariableFont_wght.ttf")
	font.size = 20

	$VBoxContainer/audio_master/MasterSliderLabel.add_font_override("font", font)
	$VBoxContainer/audio_master/MasterSliderLabel.add_color_override("font_color", Color(1, 1, 1))
	$VBoxContainer/sensitivity/SensitivitySliderLabel.add_font_override("font", font)
	$VBoxContainer/sensitivity/SensitivitySliderLabel.add_color_override("font_color", Color(1, 1, 1))
	$FullscreenToggleLabel.add_font_override("font", font)
	$FullscreenToggleLabel.add_color_override("font_color", Color(1, 1, 1))
	back_button.add_font_override("font", font)
	back_button.add_color_override("font_color", Color(1, 1, 1))

	modulate = Color(1, 1, 1, 0)
	tween.interpolate_property(self, "modulate",
		Color(1, 1, 1, 0), Color(1, 1, 1, 1),
		1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func _on_button_hover():
	hover_sound.play()

func _on_master_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))

func _on_sensitivity_changed(value: float):
	var player = get_tree().get_root().find_node("Player", true, false)
	if player:
		player.lookSensitivity = value

func _on_fullscreen_toggled(pressed: bool):
	click_sound.play()
	OS.window_fullscreen = pressed

func _on_back_pressed():
	click_sound.play()
	tween.interpolate_property(self, "modulate",
		Color(1, 1, 1, 1), Color(1, 1, 1, 0),
		0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://MainMenu.tscn")
