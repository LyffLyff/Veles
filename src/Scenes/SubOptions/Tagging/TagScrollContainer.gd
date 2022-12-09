extends ScrollContainer


var SCROLLING_SPEED : int = 50


func _ready():
	self.get_v_scrollbar().rect_min_size.x = 5
	self.get_v_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	self.get_v_scrollbar().set_step(0.05)


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_DOWN:
				self.get_v_scrollbar().value += SCROLLING_SPEED
			elif event.button_index == BUTTON_WHEEL_UP:
				self.get_v_scrollbar().value -= SCROLLING_SPEED
