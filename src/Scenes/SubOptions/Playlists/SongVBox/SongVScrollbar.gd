#Extending the functionality of the Scroll Containers VScrollbar
#Created on: 25/06/22
extends ScrollBar


var ScrollBarPressed : bool = false
signal ScrollBarReleased
signal ScrollBarPressed

func _ready():
	self.size_flags_horizontal = SIZE_SHRINK_CENTER
	self.rect_min_size.x = 5
	self.rect_min_size.y = 5
	self.rect_clip_content = false
	if self.connect("gui_input",self,"GUI_Input"):
		Global.root.message("Cannot Connect Scroller VScrollbar to GUI Input function",  SaveData.MESSAGE_ERROR )


func GUI_Input(var event) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				self.grab_click_focus()
				ScrollBarPressed = true
				self.emit_signal("ScrollBarPressed")
		else:
			if ScrollBarPressed:
				self.emit_signal("ScrollBarReleased")

