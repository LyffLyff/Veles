extends Control

onready var option_select : MarginContainer = $VBoxContainer/Header
onready var settings_scroll : ScrollContainer = $VBoxContainer/Settings/Select
onready var settings : HBoxContainer = $VBoxContainer/Settings

func _ready():
	settings_scroll.get_v_scrollbar().set_script(load("res://src/Scenes/General/StdScrollbar.gd"))
	settings_scroll.get_v_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	settings_scroll.get_v_scrollbar()._ready()
	var _err = option_select.connect("on_option_type_pressed", settings, "load_option")

