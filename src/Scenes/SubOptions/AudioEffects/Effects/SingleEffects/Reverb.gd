extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"

func _ready():
	properties = [
		"room_size",
		"damping",
		"spread",
		"hipass",
		"dry",
		"wet",
		"predelay_msec",
		"predelay_feedback"
	]
	effect_idx = 0
	call_effect_containers("init_effect_container")
