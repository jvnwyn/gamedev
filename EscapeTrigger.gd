extends Area

var hint_label: Label = null
var hint_canvas: CanvasLayer = null
var hint_timer: Timer = null

func _ready():
	connect("body_entered", self, "_on_body_entered")
	_setup_hint()

func _setup_hint():
	hint_canvas = CanvasLayer.new()
	hint_canvas.layer = 5
	get_tree().get_root().add_child(hint_canvas)
	
	hint_label = Label.new()
	hint_label.text = "You don't have the key"
	hint_label.anchor_left = 0.5
	hint_label.anchor_right = 0.5
	hint_label.anchor_top = 1.0
	hint_label.anchor_bottom = 1.0
	hint_label.margin_left = -150
	hint_label.margin_right = 150
	hint_label.margin_top = -120
	hint_label.margin_bottom = -100
	hint_label.align = Label.ALIGN_CENTER
	hint_label.modulate = Color(1, 1, 1, 0)
	hint_label.add_color_override("font_color", Color(1, 1, 1))
	
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Assets/ui/Cinzel/Cinzel-VariableFont_wght.ttf")
	dynamic_font.size = 20
	hint_label.add_font_override("font", dynamic_font)
	hint_canvas.add_child(hint_label)
	
	hint_timer = Timer.new()
	hint_timer.one_shot = true
	hint_timer.wait_time = 4.0
	hint_timer.connect("timeout", self, "_hide_hint")
	hint_canvas.add_child(hint_timer)

func _on_body_entered(body):
	if body.name == "Player":
		if PlayerData.key_collected:
			body.set_physics_process(false)
			body.set_process(false)
			var canvas = CanvasLayer.new()
			get_tree().get_root().add_child(canvas)
			var escape = preload("res://Escape.tscn").instance()
			canvas.add_child(escape)
		else:
			# Push player back
			var push_dir = body.global_transform.basis.z
			body.global_transform.origin += push_dir * 2.0
			_show_hint()

func _show_hint():
	hint_timer.stop()
	var tween = Tween.new()
	hint_canvas.add_child(tween)
	tween.interpolate_property(hint_label, "modulate:a", 0.0, 1.0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	hint_timer.start()

func _hide_hint():
	var tween = Tween.new()
	hint_canvas.add_child(tween)
	tween.interpolate_property(hint_label, "modulate:a", 1.0, 0.0, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
