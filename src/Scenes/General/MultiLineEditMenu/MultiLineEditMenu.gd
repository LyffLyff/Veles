extends "res://src/Scenes/General/LineEditMenu/LineEditMenu.gd"

export var header_title : String = ""

onready var line_edit_list = $VBoxContainer/HBoxContainer/VBoxContainer/LineEditList

func _ready():
	line_edit_list.header.text = header_title
	_err = self.connect("menu_button_pressed", self, "set_multi_line_values")


func get_line_edit_values() -> PoolStringArray:
	return line_edit_list.get_items()


func set_multi_line_values(var value) -> void:
	var values : PoolStringArray = []
	if value is String:
		values = [value]
	elif value is PoolStringArray:
		values = value
	line_edit_list.clear_items()
	line_edit_list.set_items(values)
