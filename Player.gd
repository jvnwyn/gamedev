extends KinematicBody

export var moveSpeed: float = 5.0
export var jumpForce: float = 5.0
export var gravity: float = 12.0

var minlookAngle: float = -90.0
var maxlookAngle: float = 90.0
var lookSensitivity: float = 0.5

var velocity: Vector3 = Vector3()
var mouseDelta: Vector2 = Vector2()

export var interact_distance: float = 5.0
var hovered_door = null

var snap: Vector3 = Vector3.DOWN
var is_jumping: bool = false

onready var camera = get_node("Camera")

var slot_panel: Panel
var key_slot_panel: Panel
var key_icon: TextureRect
var has_key: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.window_fullscreen = true

	var canvas = CanvasLayer.new()
	add_child(canvas)

	var control = Control.new()
	control.anchor_left = 0.0
	control.anchor_right = 1.0
	control.anchor_top = 0.0
	control.anchor_bottom = 1.0
	canvas.add_child(control)

	# Flashlight slot - centered when alone
	slot_panel = Panel.new()
	slot_panel.rect_size = Vector2(48, 48)
	slot_panel.anchor_left = 0.5
	slot_panel.anchor_right = 0.5
	slot_panel.anchor_top = 1.0
	slot_panel.anchor_bottom = 1.0
	slot_panel.margin_left = -24
	slot_panel.margin_right = 24
	slot_panel.margin_top = -64
	slot_panel.margin_bottom = -16
	control.add_child(slot_panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.4)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.8)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	slot_panel.add_stylebox_override("panel", style)

	var icon = TextureRect.new()
	icon.texture = load("res://Assets/ui/flashlight.png")
	icon.expand = true
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.anchor_left = 0.0
	icon.anchor_right = 1.0
	icon.anchor_top = 0.0
	icon.anchor_bottom = 1.0
	icon.margin_left = 4
	icon.margin_right = -4
	icon.margin_top = 4
	icon.margin_bottom = -4
	slot_panel.add_child(icon)

	var label = Label.new()
	label.text = "1"
	label.rect_position = Vector2(2, 2)
	label.add_color_override("font_color", Color(1, 1, 1))
	slot_panel.add_child(label)

	# Key slot - hidden until collected
	key_slot_panel = Panel.new()
	key_slot_panel.rect_size = Vector2(48, 48)
	key_slot_panel.anchor_left = 0.5
	key_slot_panel.anchor_right = 0.5
	key_slot_panel.anchor_top = 1.0
	key_slot_panel.anchor_bottom = 1.0
	key_slot_panel.margin_left = 32
	key_slot_panel.margin_right = 80
	key_slot_panel.margin_top = -64
	key_slot_panel.margin_bottom = -16
	key_slot_panel.visible = false
	control.add_child(key_slot_panel)

	var key_style = StyleBoxFlat.new()
	key_style.bg_color = Color(0, 0, 0, 0.4)
	key_style.border_width_left = 2
	key_style.border_width_right = 2
	key_style.border_width_top = 2
	key_style.border_width_bottom = 2
	key_style.border_color = Color(1, 1, 1, 0.8)
	key_style.corner_radius_top_left = 4
	key_style.corner_radius_top_right = 4
	key_style.corner_radius_bottom_left = 4
	key_style.corner_radius_bottom_right = 4
	key_slot_panel.add_stylebox_override("panel", key_style)

	var key_label = Label.new()
	key_label.text = "2"
	key_label.rect_position = Vector2(2, 2)
	key_label.add_color_override("font_color", Color(1, 1, 1))
	key_slot_panel.add_child(key_label)

	key_icon = TextureRect.new()
	key_icon.texture = load("res://Assets/ui/key.png")
	key_icon.expand = true
	key_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	key_icon.anchor_left = 0.0
	key_icon.anchor_right = 1.0
	key_icon.anchor_top = 0.0
	key_icon.anchor_bottom = 1.0
	key_icon.margin_left = 4
	key_icon.margin_right = -4
	key_icon.margin_top = 4
	key_icon.margin_bottom = -4
	key_slot_panel.add_child(key_icon)

func collect_key():
	has_key = true
	# Shift flashlight slot left
	slot_panel.margin_left = -52
	slot_panel.margin_right = -4
	# Show key slot right next to it
	key_slot_panel.margin_left = 4
	key_slot_panel.margin_right = 52
	key_slot_panel.visible = true

func fade_out_hud():
	if not is_inside_tree():
		return
	var tween = Tween.new()
	add_child(tween)
	yield(get_tree(), "idle_frame")
	tween.interpolate_property(slot_panel, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(key_slot_panel, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	camera.rotation_degrees -= Vector3(rad2deg(mouseDelta.y), 0, 0) * lookSensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minlookAngle, maxlookAngle)
	rotation_degrees -= Vector3(0, rad2deg(mouseDelta.x), 0) * lookSensitivity * delta
	mouseDelta = Vector2()
	_check_door_hover()

func _check_door_hover():
	var space_state = get_world().direct_space_state
	var ray_origin = camera.global_transform.origin
	var ray_dir = -camera.global_transform.basis.z
	var ray_end = ray_origin + ray_dir * interact_distance
	var result = space_state.intersect_ray(ray_origin, ray_end, [self], 0x7FFFFFFF, true, true)

	var new_hovered = null
	if result:
		var hit_node = result["collider"]
		if is_instance_valid(hit_node):
			var door = _find_door_ancestor(hit_node)
			if door and is_instance_valid(door):
				new_hovered = door

	if new_hovered != hovered_door:
		if hovered_door != null and is_instance_valid(hovered_door):
			hovered_door.set_hovered(false)
		hovered_door = new_hovered
		if hovered_door != null and is_instance_valid(hovered_door):
			hovered_door.set_hovered(true)

func _find_door_ancestor(node: Node):
	var current = node
	while current != null and current != self:
		if current.has_method("interact"):
			return current
		current = current.get_parent()
	return null

func _physics_process(delta):
	velocity.x = 0
	velocity.z = 0

	var input = Vector2()
	if Input.is_action_pressed("move_forward"):  input.y -= 1
	if Input.is_action_pressed("move_backward"): input.y += 1
	if Input.is_action_pressed("move_left"):     input.x -= 1
	if Input.is_action_pressed("move_right"):    input.x += 1
	input = input.normalized()

	var forward = global_transform.basis.z
	var right = global_transform.basis.x

	velocity.z = (forward * input.y + right * input.x).z * moveSpeed
	velocity.x = (forward * input.y + right * input.x).x * moveSpeed

	velocity.y -= gravity * delta

	if is_jumping:
		snap = Vector3.ZERO
	else:
		snap = Vector3.DOWN * 0.5

	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(46))

	if is_on_floor():
		is_jumping = false
		if velocity.y < 0:
			velocity.y = 0

	if Input.is_action_just_pressed("interact") and hovered_door != null:
		hovered_door.interact()
