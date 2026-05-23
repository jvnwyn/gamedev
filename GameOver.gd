extends Control

onready var color_rect = $ColorRect
onready var tween = $Tween
onready var you_died = $YouDied
onready var button = $BackToMenu

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	you_died.modulate = Color(1, 1, 1, 0)
	button.modulate = Color(1, 1, 1, 0)
	color_rect.color = Color(0, 0, 0, 0)
	tween.interpolate_property(
		color_rect, "color",
		Color(0, 0, 0, 0), Color(0, 0, 0, 1),
		2.5, Tween.TRANS_SINE, Tween.EASE_IN
	)
	tween.start()
	tween.connect("tween_all_completed", self, "_on_blackout_done")

func _on_blackout_done():
	tween.disconnect("tween_all_completed", self, "_on_blackout_done")
	tween.interpolate_property(
		you_died, "modulate",
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
	print("Back to menu pressed")
	get_tree().paused = false
	call_deferred("_go_to_menu")

func _go_to_menu():
	# Free the parent CanvasLayer that was dynamically added
	get_parent().get_parent().queue_free()
	get_tree().change_scene("res://MainMenu.tscn")
