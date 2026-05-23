extends Node

var current_light = null

func request_turn_on(light):
	if current_light == null:
		current_light = light
		return true
	return false

func release_light(light):
	if current_light == light:
		current_light = null
