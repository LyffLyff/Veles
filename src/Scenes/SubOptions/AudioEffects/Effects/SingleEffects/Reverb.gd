extends "res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.gd"


func _ready():
	Properties = [
		"room_size",
		"damping",
		"spread",
		"hipass",
		"dry",
		"wet",
		"predelay_msec",
		"predelay_feedback"
	]
	EffectIdx = 0
	CallEffectContainers("InitEffectContainer")
