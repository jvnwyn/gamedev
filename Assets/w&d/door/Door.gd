extends Spatial

signal door_opened(door_position)

export var open_angle: float = 90.0
export var open_speed: float = 3.0

var is_open: bool = false
var is_hovered: bool = false
var tween: Tween

var closed_rotation: float = 0.0
var target_rotation: float = 0.0

var mesh_instance = null
var audio_open = null
var audio_close = null

func _ready():
	tween = Tween.new()
	add_child(tween)
	closed_rotation = rotation_degrees.y
	target_rotation = closed_rotation
	mesh_instance = _find_mesh_instance(self)
	
	audio_open = AudioStreamPlayer3D.new()
	audio_open.stream = load("res://Assets/Audio/door-opening.wav")
	add_child(audio_open)
	
	audio_close = AudioStreamPlayer3D.new()
	audio_close.stream = load("res://Assets/Audio/door-close.wav")
	add_child(audio_close)

func _find_mesh_instance(node: Node) -> Node:
	if node is MeshInstance:
		return node
	for child in node.get_children():
		var result = _find_mesh_instance(child)
		if result:
			return result
	return null

func _find_node_by_name(node: Node, target: String) -> Node:
	if node.name == target:
		return node
	for child in node.get_children():
		var result = _find_node_by_name(child, target)
		if result:
			return result
	return null

func set_hovered(hovered: bool):
	if is_hovered == hovered:
		return
	is_hovered = hovered
	if mesh_instance == null:
		return
	if is_hovered:
		_enable_outline()
	else:
		_disable_outline()

func _enable_outline():
	if mesh_instance.get_node_or_null("OutlineMesh"):
		return
	var outline = MeshInstance.new()
	outline.name = "OutlineMesh"
	outline.mesh = mesh_instance.mesh
	var mat = SpatialMaterial.new()
	mat.flags_unshaded = true
	mat.params_cull_mode = SpatialMaterial.CULL_FRONT
	mat.albedo_color = Color(1.0, 1.0, 1.0, 0.5)
	mat.flags_transparent = true
	mat.params_grow = true
	mat.params_grow_amount = 0.04
	outline.material_override = mat
	outline.transform = Transform()
	mesh_instance.add_child(outline)

func _disable_outline():
	var outline = mesh_instance.get_node_or_null("OutlineMesh")
	if outline:
		outline.queue_free()

func interact():
	is_open = !is_open
	target_rotation = closed_rotation + open_angle if is_open else closed_rotation
	tween.stop_all()
	tween.interpolate_property(
		self, "rotation_degrees:y",
		rotation_degrees.y, target_rotation,
		1.0 / open_speed,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.start()
	if is_open and audio_open:
		audio_open.play()
	elif not is_open and audio_close:
		audio_close.play()
	# Notify the kid when door opens
	if is_open:
		emit_signal("door_opened", global_transform.origin)
