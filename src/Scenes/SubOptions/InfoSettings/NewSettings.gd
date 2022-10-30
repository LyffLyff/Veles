extends Control


#NODES
onready var OptionSelect : HBoxContainer = $VBoxContainer/HBoxContainer/OptionSelect
onready var SettingsScroll : ScrollContainer = $VBoxContainer/Settings/Select
onready var Settings : HBoxContainer = $VBoxContainer/Settings


func _ready():
	SettingsScroll.get_v_scrollbar().set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	SettingsScroll.get_v_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	SettingsScroll.get_v_scrollbar()._ready()
	var _err = OptionSelect.connect("OptionButtonPressed",Settings,"LoadOption")

