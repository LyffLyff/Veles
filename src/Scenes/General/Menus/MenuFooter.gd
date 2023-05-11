extends HBoxContainer

signal save_pressed
signal close_pressed


func _unhandled_key_input(event):
	if event.scancode == KEY_ENTER:
		_on_Save_pressed()


func _on_Close_pressed():
	self.emit_signal("close_pressed")


func _on_Save_pressed():
	self.emit_signal("save_pressed")
