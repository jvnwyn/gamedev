extends Spatial

var mesh_instance = null
var is_hovered: bool = false

func _ready():
	if PlayerData.key_collected:
		queue_free()
		return
	mesh_instance = _find_mesh_instance(self)

func _find_mesh_instance(node: Node) -> Node:
	if node is MeshInstance:
		return node
	for child in node.get_children():
		var result = _find_mesh_instance(child)
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
	var player = get_tree().get_root().find_node("Player", true, false)
	if player and player.has_method("collect_key"):
		player.collect_key()
	PlayerData.key_collected = true
	call_deferred("queue_free")
