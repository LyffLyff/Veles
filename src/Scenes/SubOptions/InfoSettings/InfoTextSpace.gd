extends "res://src/Scenes/SubOptions/InfoSettings/InfoTexts.gd"



func _ready():
	self.get_v_scroll().set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	self.get_v_scroll().set_h_size_flags(SIZE_SHRINK_CENTER)
	self.get_v_scroll()._ready()


func SetInfoText(var SubInfoIdx : int, var SubInfoTypeIdx : int) -> void:
	self.set_bbcode(
		Infos.values()[ SubInfoTypeIdx ].values()[ SubInfoIdx ]
	)
