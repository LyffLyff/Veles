extends "res://src/Scenes/SubOptions/InfoSettings/InfoTexts.gd"

func _ready():
	self.get_v_scroll().set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	self.get_v_scroll().set_h_size_flags(SIZE_SHRINK_CENTER)
	self.get_v_scroll()._ready()


func set_info_text(var subinfo_idx : int, var subinfo_type_text : int) -> void:
	self.set_bbcode(
		infos.values()[subinfo_type_text].values()[subinfo_idx]
	)
