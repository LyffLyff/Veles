extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"

func _ready():
	properties = [
		"pitch_scale"
	]
	effect_idx = 2
	call_effect_containers("init_effect_container")
