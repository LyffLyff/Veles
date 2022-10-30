extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"


func _ready():
	Properties = [
		"pan"
	]
	EffectIdx = 4
	CallEffectContainers("InitEffectContainer")
