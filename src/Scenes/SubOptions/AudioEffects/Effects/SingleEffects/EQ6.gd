extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"


func _ready():
	Properties = [
		"band_db/32_hz",
		"band_db/100_hz",
		"band_db/320_hz",
		"band_db/1000_hz",
		"band_db/3200_hz",
		"band_db/10000_hz"
	]
	EffectIdx = 5
	CallEffectContainers("InitEffectContainer")
