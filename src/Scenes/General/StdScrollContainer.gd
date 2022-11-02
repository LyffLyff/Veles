extends ScrollContainer


func _ready():
	#Init H-Scrollbar
	self.get_h_scrollbar().set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	self.get_h_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	self.get_h_scrollbar()._ready()
	
	#Init V-Scrollbar
	self.get_v_scrollbar().set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	self.get_v_scrollbar().set_v_size_flags(SIZE_SHRINK_CENTER)
	self.get_v_scrollbar()._ready()
