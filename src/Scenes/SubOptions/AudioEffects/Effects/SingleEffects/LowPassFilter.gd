extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"

func _ready():
	properties = [
		"cutoff_hz",
		"resonance",
		"db"
	]
	effect_idx = 3
	call_effect_containers("init_effect_container")
