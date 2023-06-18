extends MarginContainer

signal on_option_type_pressed

var selected_option_idx : int = 0

onready var options = $HBoxContainer


func _ready():
	var _err
	for i in options.get_child_count():
		_err = options.get_child(i).connect("pressed", self,"emit_signal",["on_option_type_pressed",i])
		_err = options.get_child(i).connect("pressed", self,"set_option_type",[i])
	set_option_type(0)


func set_option_type(var option_idx : int) -> void:
	options.get_child(selected_option_idx).set("custom_styles/normal", null)
	selected_option_idx = option_idx
	options.get_child(selected_option_idx).set("custom_styles/normal", load("res://src/Ressources/Themes/flat_1px__white_outline.tres"))
