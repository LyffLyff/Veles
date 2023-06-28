extends OptionButton


func _unhandled_key_input(event):
	if event.scancode == KEY_ENTER:
		self.release_focus()
