extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"


func _ready():
	Properties = [
		"pitch_scale"
	]
	EffectIdx = 2
	CallEffectContainers("InitEffectContainer")
