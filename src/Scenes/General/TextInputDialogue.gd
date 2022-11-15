extends "res://src/Scenes/General/StdPopupBackground.gd"
# a general input popup that can receive input via a LineEdit

signal text_saved

onready var topic_label : Label = $PanelContainer/HBoxContainer/VBoxContainer/TopicLabel
onready var input_edit : LineEdit = $PanelContainer/HBoxContainer/VBoxContainer/Input/InputEdit
onready var dialogue_button : TextureButton = $PanelContainer/HBoxContainer/VBoxContainer/Input/FileDialogue


func init_dialogue_button(var open_mode : int = FileDialog.MODE_OPEN_FILE, var file_access : int = FileDialog.ACCESS_FILESYSTEM, file_type : String = "Cover", file_filters : PoolStringArray = []) -> void:
	dialogue_button.show()
	var _err = dialogue_button.connect("pressed",Global.root,"load_general_file_dialogue",[
		input_edit,
		open_mode,
		file_access,
		"set_text",
		[],
		file_type,
		file_filters,
		true
	])


func set_topic(var topic : String) -> void:
	topic_label.set_text(topic)


func _on_Close_pressed():
	exit_popup()


func _on_Save_pressed():
	emit_signal("text_saved", input_edit.get_text() )
	exit_popup()
