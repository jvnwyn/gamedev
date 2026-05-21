extends Node

# Floor scene paths
const FLOORS = {
	1: "res://1stFloor.tscn",
	2: "res://2ndFloor.tscn",
	4: "res://4thFloor.tscn",
	5: "res://5thFloor.tscn"
}

# Where the player spawns when arriving on each floor
# Set these to match your stair positions on each floor
const SPAWN_POINTS = {
	1: Vector3(143.152, 4.826, -7.871),
	2: Vector3(143.152, 4.826, -6.367),
	4: Vector3(143.19, 4.826, -6.367),
	5: Vector3(143.19, 4.826, -6.367)
}

const FLOOR_ORDER = [1, 2, 4, 5]

var current_floor: int = 4
var current_floor_instance: Node = null

onready var player = get_node("../Player")
onready var kid = get_node("../Kid")

func _ready():
	load_floor(current_floor)

func load_floor(floor_num: int):
	# Unload current floor
	if current_floor_instance:
		current_floor_instance.queue_free()
		current_floor_instance = null

	# Load new floor
	var scene = load(FLOORS[floor_num])
	current_floor_instance = scene.instance()
	get_parent().add_child(current_floor_instance)
	current_floor = floor_num

	# Move player to spawn point
	if player:
		player.global_transform.origin = SPAWN_POINTS[floor_num]

	# Reconnect kid's door signals on new floor
	if kid:
		kid.call_deferred("_connect_doors")

func go_up():
	var idx = FLOOR_ORDER.find(current_floor)
	if idx < FLOOR_ORDER.size() - 1:
		load_floor(FLOOR_ORDER[idx + 1])

func go_down():
	var idx = FLOOR_ORDER.find(current_floor)
	if idx > 0:
		load_floor(FLOOR_ORDER[idx - 1])
