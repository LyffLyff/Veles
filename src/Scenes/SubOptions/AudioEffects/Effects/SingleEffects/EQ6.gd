extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"

func _ready():
	properties = [
		"band_db/32_hz",
		"band_db/100_hz",
		"band_db/320_hz",
		"band_db/1000_hz",
		"band_db/3200_hz",
		"band_db/10000_hz"
	]
	effect_idx = 5
	call_effect_containers("init_effect_container")
