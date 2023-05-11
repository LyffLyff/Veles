extends Control

signal outside_input

func _input(event):
	# delete on any mouse input outside of lineedit
	if event is InputEventMouseButton and event.pressed and !self.get_global_rect().has_point(get_global_mouse_position()):
		self.emit_signal("outside_input")
		self.set_process(false)
