extends "res://src/Scenes/General/StdPopupBackground.gd"
# a general input popup that can receive input via a LineEdit

signal text_saved
signal saved

onready var topic_label : Label = $PanelContainer/MarginContainer/VBoxContainer/TopicLabel
onready var input_edit : LineEdit = $PanelContainer/MarginContainer/VBoxContainer/Input/InputEdit
onready var dialogue_button : TextureButton = $PanelContainer/MarginContainer/VBoxContainer/Input/FileDialogue
onready var menu_footer = $PanelContainer/MarginContainer/VBoxContainer/MenuFooter

func _ready():
	menu_footer.connect("save_pressed", self, "_on_Save_pressed")
	menu_footer.connect("close_pressed", self, "_on_Close_pressed")


func init_dialogue_button(var open_mode : int = FileDialog.MODE_OPEN_FILE, var file_access : int = FileDialog.ACCESS_FILESYSTEM, file_type : int = UsedFilepaths.DESKTOP, file_filters : PoolStringArray = []) -> void:
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
	topic_label.set_text(topic + ":")


func set_default_value(var default_value : String) -> void:
	input_edit.text = default_value


func _on_Close_pressed():
	exit_popup()


func _on_Save_pressed():
	emit_signal("text_saved", input_edit.get_text())
	emit_signal("saved")
	exit_popup()
