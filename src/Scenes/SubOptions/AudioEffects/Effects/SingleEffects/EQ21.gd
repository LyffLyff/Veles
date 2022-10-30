extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"


func _ready():
	Properties = [
		"band_db/22_hz",
		"band_db/32_hz",
		"band_db/44_hz",
		"band_db/63_hz",
		"band_db/90_hz",
		"band_db/125_hz",
		"band_db/175_hz",
		"band_db/250_hz",
		"band_db/350_hz",
		"band_db/500_hz",
		"band_db/700_hz",
		"band_db/1000_hz",
		"band_db/1400_hz",
		"band_db/2000_hz",
		"band_db/2800_hz",
		"band_db/4000_hz",
		"band_db/5600_hz",
		"band_db/8000_hz",
		"band_db/11000_hz",
		"band_db/16000_hz",
		"band_db/22000_hz",
	]
	EffectIdx = 6
	CallEffectContainers("InitEffectContainer")
