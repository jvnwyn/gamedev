extends Node

const FLOORS = {
	1: "res://1stFloor.tscn",
	2: "res://2ndFloor.tscn",

}

const SPAWN_POINTS = {
	1: Vector3(138.19, 4.234, -9.903),
	2: Vector3(143.19, 4.826, -6.367)
}

const FLOOR_ORDER = [1, 2]

var current_floor: int = 1
var current_floor_instance: Node = null
var is_first_load: bool = true

onready var player = get_node("../Player")
onready var kid = get_node("../kid")

func _ready():
	call_deferred("load_floor", current_floor)

func load_floor(floor_num: int):
	if current_floor_instance:
		current_floor_instance.queue_free()
		current_floor_instance = null

	var scene = load(FLOORS[floor_num])
	current_floor_instance = scene.instance()
	get_parent().add_child(current_floor_instance)
	current_floor = floor_num

	yield(get_tree(), "idle_frame")

	# Only move player to spawn point when switching floors, not on first load
	if not is_first_load:
		if player:
			player.global_transform.origin = SPAWN_POINTS[floor_num]
	
	is_first_load = false

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
