extends KinematicBody

export var walk_speed: float = 10.0
export var run_speed: float = 20.0
export var run_distance: float = 20.0
export var kill_distance: float = 6.0
export var stop_distance: float = 6.0
export var detect_distance: float = 50.0

var player: Node = null
var anim_player: AnimationPlayer = null
var is_dead: bool = false
var is_moving: bool = false
var velocity: Vector3 = Vector3.ZERO

var door_waypoint: Vector3 = Vector3.ZERO
var has_waypoint: bool = false

const KID_SPAWN_POINTS = {
	1: {
		"left": Vector3(-156.683899, -13.050052, -6.316),
		"right": Vector3(139.354446, -13.050052, 8.122311)
	},
	2: {
		"left": Vector3(-148.320618, -5.89223, -9.219653),
		"right": Vector3(161.127502, -5.89223, 7.395763)
	}
}

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)
	set_process(false)
	set_physics_process(false)
	return

func teleport_to_opposite_stair(floor_num: int):
	var opposite = "right" if PlayerData.last_stair_id == "left" else "left"
	if KID_SPAWN_POINTS.has(floor_num) and KID_SPAWN_POINTS[floor_num].has(opposite):
		global_transform.origin = KID_SPAWN_POINTS[floor_num][opposite]

func _connect_doors():
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		if door.has_signal("door_opened"):
			door.connect("door_opened", self, "_on_door_opened")

func _on_door_opened(door_position: Vector3):
	var dist_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	if dist_to_player > detect_distance:
		has_waypoint = true
		door_waypoint = door_position

func _find_node_by_name(node: Node, target: String) -> Node:
	if node.name == target:
		return node
	for child in node.get_children():
		var result = _find_node_by_name(child, target)
		if result:
			return result
	return null

func _is_path_clear(direction: Vector3) -> bool:
	var space = get_world().direct_space_state
	var origin = global_transform.origin + Vector3.UP * 1.0
	var end = origin + direction * 8.0
	var result = space.intersect_ray(origin, end, [self, player])
	return not result

func _get_steering_direction(desired_dir: Vector3) -> Vector3:
	if _is_path_clear(desired_dir):
		return desired_dir
	var angles = [-30, 30, -60, 60, -90, 90, -120, 120]
	for angle in angles:
		var rotated = desired_dir.rotated(Vector3.UP, deg2rad(angle))
		if _is_path_clear(rotated):
			return rotated
	return desired_dir

func _physics_process(delta):
	if player == null or is_dead:
		return

	var dist_to_player = global_transform.origin.distance_to(player.global_transform.origin)

	if dist_to_player <= kill_distance:
		_kill_player()
		return

	var target_pos: Vector3
	var in_range: bool = false

	if dist_to_player <= detect_distance:
		target_pos = player.global_transform.origin
		has_waypoint = false
		in_range = true
	elif has_waypoint:
		target_pos = door_waypoint
		in_range = true
		if global_transform.origin.distance_to(door_waypoint) < 5.0:
			has_waypoint = false

	if in_range:
		if dist_to_player <= run_distance:
			AudioManager.play_hunt()
		else:
			AudioManager.stop_hunt()

		if dist_to_player <= stop_distance:
			velocity = Vector3.ZERO
			var look_target = Vector3(player.global_transform.origin.x, global_transform.origin.y, player.global_transform.origin.z)
			look_at(look_target, Vector3.UP)
		else:
			var desired = (target_pos - global_transform.origin)
			desired.y = 0
			desired = desired.normalized()

			var move_dir = _get_steering_direction(desired)
			var speed = run_speed if dist_to_player <= run_distance else walk_speed

			velocity.x = move_dir.x * speed
			velocity.y = 0
			velocity.z = move_dir.z * speed

			var look_target = global_transform.origin + Vector3(move_dir.x, 0, move_dir.z)
			look_at(look_target, Vector3.UP)

			if anim_player:
				if not anim_player.is_playing():
					anim_player.play("walking")
				anim_player.playback_speed = 2.5 if dist_to_player <= run_distance else 1.0
		is_moving = true
	else:
		AudioManager.stop_hunt()
		velocity = Vector3.ZERO
		if anim_player and is_moving:
			anim_player.stop()
			is_moving = false

	move_and_slide(velocity, Vector3.UP)
	
func _kill_player():
	is_dead = true
	velocity = Vector3.ZERO
	if anim_player:
		anim_player.stop()

	AudioManager.play_kid_laugh()

	if player:
		player.set_physics_process(false)
		player.set_process(false)
		player.set_process_input(false)

	var canvas = CanvasLayer.new()
	get_tree().get_root().add_child(canvas)
	var game_over = preload("res://GameOver.tscn").instance()
	canvas.add_child(game_over)
