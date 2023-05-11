extends "res://src/Scenes/General/OutsideInputCheck.gd"

onready var spin_box : SpinBox = $"."
onready var line_edit : LineEdit = spin_box.get_line_edit()

onready var prior_text : String = line_edit.text

func _ready():
	line_edit.selecting_enabled = false
	
	# hiding caret
	line_edit.set("custom_colors/cursor_color", Color(0,0,0,0))
	self.connect("outside_input", line_edit, "release_focus")
	
	# update value
	on_spinbox_text_edited("")
	line_edit.connect("text_changed", self, "on_spinbox_text_edited")
	line_edit.connect("text_entered", self, "on_text_entered")


func on_spinbox_text_edited(var new_text : String) -> void:
	if new_text == "":
		pass
	
	if new_text == "<retain>":
		line_edit.text = new_text
	
	elif new_text.is_valid_integer():
		prior_text = new_text
		spin_box.set_value(int(new_text))
	else:
		line_edit.text = prior_text
	
	line_edit.caret_position = line_edit.text.length()


func on_text_entered(var _n_text : String) -> void:
	self.release_focus()
	line_edit.release_focus()
