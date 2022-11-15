extends ScrollContainer

const std_scrollbar : GDScript = preload("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd")

func _ready(): 
	# init h-Scrollbar
	self.get_h_scrollbar().set_script( std_scrollbar )
	self.get_h_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	self.get_h_scrollbar()._ready()
	
	# onit v-Scrollbar
	self.get_v_scrollbar().set_script( std_scrollbar )
	self.get_v_scrollbar().set_v_size_flags(SIZE_SHRINK_CENTER)
	self.get_v_scrollbar()._ready()
