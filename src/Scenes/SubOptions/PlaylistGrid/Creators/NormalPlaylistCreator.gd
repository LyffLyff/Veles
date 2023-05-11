extends "res://src/Scenes/SubOptions/PlaylistGrid/Creators/PlaylistCreatorMain.gd"

onready var title : LineEdit = $Panel/MarginContainer/Main/Name/InputEdit
onready var cover_hbox : HBoxContainer = $Panel/MarginContainer/Main/Cover


func _ready():
	var _err = footer.connect("save_pressed", self, "_on_Save_pressed")


func _on_Save_pressed() -> void:
	emit_signal("save",title.get_text(), cover_hbox.input_edit.get_text(), "")
	self.exit_popup()
