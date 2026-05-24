extends Area

export var goes_up: bool = true
export var stair_id: String = "left"

var active: bool = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_done")
	timer.start()

func _on_timer_done():
	active = true

func _on_body_entered(body):
	print("body entered: ", body.name)
	if not active:
		print("not active yet")
		return
	if body.name == "Player":
		print("player detected, going up: ", goes_up)
		PlayerData.last_stair_id = stair_id
		var floor_manager = get_tree().get_root().find_node("FloorManager", true, false)
		if floor_manager == null:
			return
		if goes_up:
			floor_manager.go_up()
		else:
			floor_manager.go_down()
