extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"


func _ready():
	Properties = [
		"pan_pullout",
		"time_pullout_ms",
		"surround"
	]
	EffectIdx = 1
	CallEffectContainers("InitEffectContainer")
