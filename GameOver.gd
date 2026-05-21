extends Control

onready var color_rect = $ColorRect
onready var tween = $Tween
onready var you_died = $YouDied

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	you_died.modulate = Color(1, 1, 1, 0)
	color_rect.color = Color(0, 0, 0, 0)
	tween.interpolate_property(
		color_rect, "color",
		Color(0, 0, 0, 0), Color(0, 0, 0, 1),
		2.5, Tween.TRANS_SINE, Tween.EASE_IN
	)
	tween.start()
	tween.connect("tween_all_completed", self, "_on_blackout_done")

func _on_blackout_done():
	# Disconnect so this never fires again
	tween.disconnect("tween_all_completed", self, "_on_blackout_done")
	tween.interpolate_property(
		you_died, "modulate",
		Color(1, 1, 1, 0), Color(1, 1, 1, 1),
		1.5, Tween.TRANS_SINE, Tween.EASE_IN
	)
	tween.start()

func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_QuitButton_pressed():
	get_tree().quit()
