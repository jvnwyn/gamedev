extends Spatial
 
export var open_angle: float = 90.0
export var open_speed: float = 3.0
 
var is_open: bool = false
var is_hovered: bool = false
var tween: Tween
 
var door_left = null
var door_right = null
var closed_rotation_left: float = 0.0
var closed_rotation_right: float = 0.0
 
var mesh_left = null
var mesh_right = null
 
var audio_open = null
var audio_close = null
 
func _ready():
	tween = Tween.new()
	add_child(tween)
 
	# Grab the two door body nodes by name
	door_left = _find_node_by_name(self, "Body70")
	door_right = _find_node_by_name(self, "Body71")
 
	if door_left:
		closed_rotation_left = door_left.rotation_degrees.y
		mesh_left = _find_mesh_instance(door_left)
	if door_right:
		closed_rotation_right = door_right.rotation_degrees.y
		mesh_right = _find_mesh_instance(door_right)
 
	audio_open = _find_node_by_name(self, "AudioOpen")
	audio_close = _find_node_by_name(self, "AudioClose")
 
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
	if is_hovered:
		if mesh_left:
			_enable_outline(mesh_left)
		if mesh_right:
			_enable_outline(mesh_right)
	else:
		if mesh_left:
			_disable_outline(mesh_left)
		if mesh_right:
			_disable_outline(mesh_right)
 
func _enable_outline(mesh: Node):
	if mesh.get_node_or_null("OutlineMesh"):
		return
	var outline = MeshInstance.new()
	outline.name = "OutlineMesh"
	outline.mesh = mesh.mesh
	var mat = SpatialMaterial.new()
	mat.flags_unshaded = true
	mat.params_cull_mode = SpatialMaterial.CULL_FRONT
	mat.albedo_color = Color(1.0, 1.0, 1.0, 0.5)
	mat.flags_transparent = true
	mat.params_grow = true
	mat.params_grow_amount = 0.04
	outline.material_override = mat
	outline.transform = Transform()
	mesh.add_child(outline)
 
func _disable_outline(mesh: Node):
	var outline = mesh.get_node_or_null("OutlineMesh")
	if outline:
		outline.queue_free()
 
func interact():
	is_open = !is_open
	tween.stop_all()
 
	if door_left:
		var target_left = closed_rotation_left - open_angle if is_open else closed_rotation_left
		tween.interpolate_property(
			door_left, "rotation_degrees:y",
			door_left.rotation_degrees.y, target_left,
			1.0 / open_speed,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
 
	if door_right:
		var target_right = closed_rotation_right + open_angle if is_open else closed_rotation_right
		tween.interpolate_property(
			door_right, "rotation_degrees:y",
			door_right.rotation_degrees.y, target_right,
			1.0 / open_speed,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
 
	tween.start()
 
	if is_open and audio_open:
		audio_open.play()
	elif not is_open and audio_close:
		audio_close.play()

func unlock():
	if not is_open:
		interact()
