extends Node

var ambience: AudioStreamPlayer
var kid_laugh: AudioStreamPlayer
var hunt: AudioStreamPlayer
var tween: Tween

func _ready():
	tween = Tween.new()
	add_child(tween)
	
	ambience = AudioStreamPlayer.new()
	ambience.stream = load("res://Assets/Audio/ambience.wav")
	ambience.autoplay = false
	ambience.volume_db = -80
	ambience.bus = "Master"
	add_child(ambience)
	
	kid_laugh = AudioStreamPlayer.new()
	kid_laugh.stream = load("res://Assets/Audio/kid-laugh.wav")
	kid_laugh.autoplay = false
	kid_laugh.bus = "Master"
	add_child(kid_laugh)
	
	hunt = AudioStreamPlayer.new()
	hunt.stream = load("res://Assets/Audio/hunt.wav")
	hunt.autoplay = false
	hunt.bus = "Master"
	add_child(hunt)

func play_ambience():
	if not ambience.playing:
		ambience.volume_db = -80
		ambience.play()
	tween.stop_all()
	tween.interpolate_property(ambience, "volume_db", -80, -10, 5.0, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func stop_ambience():
	ambience.stop()
	ambience.volume_db = -80

func play_kid_laugh():
	stop_ambience()
	stop_hunt()
	kid_laugh.play()

func stop_kid_laugh():
	kid_laugh.stop()

func play_hunt():
	if not hunt.playing:
		stop_ambience()
		hunt.play()

func stop_hunt():
	if hunt.playing:
		hunt.stop()
		play_ambience()
