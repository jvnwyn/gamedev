
extends Node

const FLOORS = {
	1: "res://1stFloor.tscn",
	2: "res://4thFloor.tscn"
}

const FLOOR_NAMES = {
	1: "1st Floor",
	2: "4th Floor"
}

const SPAWN_POINTS = {
	1: {
		"left": Vector3(-215.921326, -5.678852, 14.360372),
		"right": Vector3(81.658096, -5.678852, 33.628777)
	},
	2: {
		"left": Vector3(-215.921326, -5.678852, 14.360372),
		"right": Vector3(81.658096, -5.678852, 33.628777)
	}
}

const FLOOR_ORDER = [1, 2]

var current_floor: int = 1
var current_floor_instance: Node = null
var is_first_load: bool = true

var transition_canvas: CanvasLayer = null
var fade_rect: ColorRect = null
var floor_label: Label = null
var tween: Tween = null

onready var player = get_node("../Player")
onready var kid = get_node("../kid")

func _ready():
	_setup_transition_ui()
	call_deferred("load_floor", current_floor)

func _setup_transition_ui():
	transition_canvas = CanvasLayer.new()
	transition_canvas.layer = 10
	get_parent().add_child(transition_canvas)

	fade_rect = ColorRect.new()
	fade_rect.anchor_left = 0.0
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_top = 0.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_canvas.add_child(fade_rect)

	floor_label = Label.new()
	floor_label.anchor_left = 0.0
	floor_label.anchor_right = 1.0
	floor_label.anchor_top = 0.0
	floor_label.anchor_bottom = 0.0
	floor_label.margin_top = 40
	floor_label.margin_bottom = 80
	floor_label.align = Label.ALIGN_CENTER
	floor_label.modulate = Color(1, 1, 1, 0)
	floor_label.add_color_override("font_color", Color(1, 1, 1))
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Assets/ui/Cinzel/Cinzel-VariableFont_wght.ttf")
	dynamic_font.size = 32
	floor_label.add_font_override("font", dynamic_font)
	transition_canvas.add_child(floor_label)

	tween = Tween.new()
	get_parent().add_child(tween)

func load_floor(floor_num: int):
	if current_floor_instance:
		current_floor_instance.queue_free()
		current_floor_instance = null

	var scene = load(FLOORS[floor_num])
	current_floor_instance = scene.instance()
	get_parent().add_child(current_floor_instance)
	current_floor = floor_num

	yield(get_tree(), "idle_frame")

	if not is_first_load:
		if player:
			var stair = PlayerData.last_stair_id
			player.global_transform.origin = SPAWN_POINTS[floor_num][stair]
		if kid:
			kid.teleport_to_opposite_stair(floor_num)
		_do_transition(floor_num)

	is_first_load = false

	if kid:
		kid.call_deferred("_connect_doors")

func _do_transition(floor_num: int):
	tween.stop_all()
	tween.interpolate_property(fade_rect, "color",
		Color(0, 0, 0, 0), Color(0, 0, 0, 1),
		0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	floor_label.text = FLOOR_NAMES[floor_num]
	tween.interpolate_property(floor_label, "modulate",
		Color(1, 1, 1, 0), Color(1, 1, 1, 1),
		0.4, Tween.TRANS_SINE, Tween.EASE_IN, 0.5)
	tween.interpolate_property(floor_label, "modulate",
		Color(1, 1, 1, 1), Color(1, 1, 1, 0),
		0.4, Tween.TRANS_SINE, Tween.EASE_OUT, 2.1)
	tween.interpolate_property(fade_rect, "color",
		Color(0, 0, 0, 1), Color(0, 0, 0, 0),
		0.5, Tween.TRANS_SINE, Tween.EASE_OUT, 2.5)
	tween.start()

func go_up():
	var idx = FLOOR_ORDER.find(current_floor)
	if idx < FLOOR_ORDER.size() - 1:
		load_floor(FLOOR_ORDER[idx + 1])

func go_down():
	var idx = FLOOR_ORDER.find(current_floor)
	if idx > 0:
		load_floor(FLOOR_ORDER[idx - 1])

