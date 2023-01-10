#Extending the functionality of the Scroll Containers VScrollbar
#Created on: 25/06/22
extends ScrollBar

signal scrollbar_released
signal scrollbar_pressed

var is_scrollbar_pressed : bool = false

func _ready():
	self.size_flags_horizontal = SIZE_SHRINK_CENTER
	self.rect_min_size.x = 5
	self.rect_min_size.y = 5
	self.rect_clip_content = false
	if self.connect("gui_input",self,"_on_gui_input"):
		Global.root.message("Cannot Connect Scroller VScrollbar to GUI Input function",  SaveData.MESSAGE_ERROR )


func _on_gui_input(var event) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				self.grab_click_focus()
				is_scrollbar_pressed = true
				self.emit_signal("scrollbar_pressed")
		else:
			if is_scrollbar_pressed:
				self.emit_signal("scrollbar_released")

