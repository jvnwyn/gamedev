extends KinematicBody

export var walk_speed: float = 10.0
export var run_speed: float = 20.0
export var run_distance: float = 15.0
export var kill_distance: float = 5.0
export var detect_distance: float = 50.0

var player: Node = null
var anim_player: AnimationPlayer = null
var is_dead: bool = false
var is_moving: bool = false
var velocity: Vector3 = Vector3.ZERO

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)
	anim_player = _find_node_by_name(self, "AnimationPlayer")

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
	var end = origin + direction * 3.0
	var result = space.intersect_ray(origin, end, [self])
	return not result

func _get_steering_direction(desired_dir: Vector3) -> Vector3:
	# First try going straight at the player
	if _is_path_clear(desired_dir):
		return desired_dir
	# Path blocked — try angled directions
	var angles = [-30, 30, -60, 60, -90, 90]
	for angle in angles:
		var rotated = desired_dir.rotated(Vector3.UP, deg2rad(angle))
		if _is_path_clear(rotated):
			return rotated
	return desired_dir

func _physics_process(delta):
	if player == null or is_dead:
		return

	var dist = global_transform.origin.distance_to(player.global_transform.origin)

	if dist <= kill_distance:
		_kill_player()
		return

	if dist <= detect_distance:
		var desired = (player.global_transform.origin - global_transform.origin)
		desired.y = 0
		desired = desired.normalized()

		var move_dir = _get_steering_direction(desired)
		var speed = run_speed if dist <= run_distance else walk_speed

		velocity.x = move_dir.x * speed
		velocity.y = 0
		velocity.z = move_dir.z * speed

		# Face movement direction
		var target_pos = global_transform.origin + Vector3(move_dir.x, 0, move_dir.z)
		look_at(target_pos, Vector3.UP)

		if anim_player:
			if not anim_player.is_playing():
				anim_player.play("walking")
			anim_player.playback_speed = 2.5 if dist <= run_distance else 1.0
		is_moving = true
	else:
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

	if player:
		player.set_physics_process(false)
		player.set_process(false)
		player.set_process_input(false)

	var canvas = CanvasLayer.new()
	get_tree().get_root().add_child(canvas)
	var game_over = preload("res://GameOver.tscn").instance()
	canvas.add_child(game_over)
