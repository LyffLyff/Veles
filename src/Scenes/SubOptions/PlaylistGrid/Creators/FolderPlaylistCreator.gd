extends "res://src/Scenes/SubOptions/PlaylistGrid/Creators/PlaylistCreatorMain.gd"

onready var title : HBoxContainer = $Panel/MarginContainer/VBoxContainer/Title
onready var cover_hbox : HBoxContainer = $Panel/MarginContainer/VBoxContainer/Cover
onready var folder : HBoxContainer = $Panel/MarginContainer/VBoxContainer/FolderPath


func _ready():
	var _err = footer.connect("save_pressed", self, "on_save_pressed")


func on_save_pressed() -> void:
	var p_folder : String = folder.input_edit.get_text()
	var p_title : String = title.input_edit.get_text()
	var p_coverpath : String = cover_hbox.input_edit.get_text()
	emit_signal("save", p_title, p_coverpath, p_folder)
	self.exit_popup()
