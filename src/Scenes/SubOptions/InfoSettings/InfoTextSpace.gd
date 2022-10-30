extends "res://src/Scenes/SubOptions/InfoSettings/InfoTexts.gd"


func SetInfoText(var SubInfoIdx : int, var SubInfoTypeIdx : int) -> void:
	self.set_bbcode(
		Infos.values()[ SubInfoTypeIdx ].values()[ SubInfoIdx ]
	)
