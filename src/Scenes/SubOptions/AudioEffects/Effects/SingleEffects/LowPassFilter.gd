extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"


func _ready():
	Properties = [
		"cutoff_hz",
		"resonance",
		"db"
	]
	EffectIdx = 3
	CallEffectContainers("InitEffectContainer")
