extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"

func _ready():
	properties = [
		"pan"
	]
	effect_idx = 4
	call_effect_containers("init_effect_container")
