extends "res://src/Scenes/General/LineEditMenu/LineEditMenu.gd"

onready var line_edit : LineEdit = $VBoxContainer/HBoxContainer/VBoxContainer/LineEdit


func _ready():
	_err = self.connect("outside_input", line_edit, "release_focus")
	_err = self.connect("menu_button_pressed", line_edit, "set_text")
	_err = line_edit.connect("text_entered", self, "on_line_edit_text_entered")


func on_line_edit_text_entered(var _new_text : String) -> void:
	line_edit.release_focus()


func get_text() -> String:
	return line_edit.text
