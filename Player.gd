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

# Snap vector keeps player stuck to ground/stairs when not jumping
var snap: Vector3 = Vector3.DOWN
var is_jumping: bool = false

onready var camera = get_node("Camera")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.window_fullscreen = true

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
		var door = _find_door_ancestor(hit_node)
		if door:
			new_hovered = door

	if new_hovered != hovered_door:
		if hovered_door != null:
			hovered_door.set_hovered(false)
		hovered_door = new_hovered
		if hovered_door != null:
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

	# Disable snap while jumping so we actually leave the ground
	if is_jumping:
		snap = Vector3.ZERO
	else:
		snap = Vector3.DOWN * 0.5

	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(46))

	if is_on_floor():
		is_jumping = false
		# Kill downward velocity so gravity doesn't accumulate on slopes/stairs
		if velocity.y < 0:
			velocity.y = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
		is_jumping = true
		snap = Vector3.ZERO

	if Input.is_action_just_pressed("interact") and hovered_door != null:
		hovered_door.interact()
