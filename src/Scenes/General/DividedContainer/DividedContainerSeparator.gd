extends VSeparator

var start_mouse_x : int = -1
var start_resize_length : int = -1

func _ready():
	self.set_process(false)
	self.size_flags_vertical = SIZE_EXPAND_FILL
	self.rect_min_size.x = 5


func _process(var _delta):
	get_parent().get_child(self.get_index() - 1).rect_min_size.x = start_resize_length - (start_mouse_x - get_global_mouse_position().x)


func _on_DividedContainerSeparator_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			start_resize_length = get_parent().get_child(self.get_index() - 1).rect_size.x
			start_mouse_x = int(get_global_mouse_position().x)
			self.set_process(true)
		else:
			self.set_process(false)
			start_mouse_x = -1
