extends ScrollContainer


func _ready():
	self.get_h_scrollbar().set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	self.get_h_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	self.get_h_scrollbar()._ready()
