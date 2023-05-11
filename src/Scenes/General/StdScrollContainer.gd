extends ScrollContainer

const std_scrollbar : GDScript = preload("res://src/Scenes/General/StdScrollbar.gd")

func _ready(): 
	# init h-Scrollbar
	self.get_h_scrollbar().set_script(std_scrollbar)
	self.get_h_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	self.get_h_scrollbar().step = 0.01
	self.get_h_scrollbar()._ready()
	
	# init v-Scrollbar
	self.get_v_scrollbar().step = 0.01
	self.get_v_scrollbar().set_script(std_scrollbar)
	self.get_v_scrollbar().set_v_size_flags(SIZE_SHRINK_CENTER)
	self.get_v_scrollbar()._ready()
