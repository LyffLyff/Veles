extends HBoxContainer

signal on_option_type_pressed

var selected_option_idx : int = 0

func _ready():
	var _err
	for i in self.get_child_count():
		_err = self.get_child(i).connect("pressed",self,"emit_signal",["on_option_type_pressed",i])
		_err = self.get_child(i).connect("pressed",self,"set_option_type",[i])
	set_option_type(0)


func set_option_type(var option_idx : int) -> void:
	self.get_child( selected_option_idx ).theme = load("res://src/Themes/Buttons/SidebarButtonsUnpressed.tres")
	selected_option_idx = option_idx
	self.get_child( selected_option_idx ).theme = load("res://src/Themes/Buttons/SidebarButtonsPressed.tres")
