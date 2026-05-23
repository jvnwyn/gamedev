extends OmniLight

export var min_on_time = 1.0
export var max_on_time = 5.0
export var min_off_time = 0.5
export var max_off_time = 3.0

func _ready():
	randomize()
	visible = false
	_try_turn_on()

func _try_turn_on():
	var wait = rand_range(min_off_time, max_off_time)
	yield(get_tree().create_timer(wait), "timeout")
	
	if LightManager.request_turn_on(self):
		visible = true
		var on_time = rand_range(min_on_time, max_on_time)
		yield(get_tree().create_timer(on_time), "timeout")
		visible = false
		LightManager.release_light(self)
