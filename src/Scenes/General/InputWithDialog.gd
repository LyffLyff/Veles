extends HBoxContainer
# a LinedEdit that can receive input via a filedialogue and manually

signal dialogue_pressed

onready var input_label : Label = $InputLabel
onready var input_edit : LineEdit = $InputEdit
onready var Dialogue : TextureButton = $Dialogue

export var input_label_text : String = ""
export var open_mode : int = 0
export var file_type : String = ""
export var show_file_dialogue : bool = false


func _ready():
	input_label.text = input_label_text
	if !show_file_dialogue:
		Dialogue.hide()


func get_text() -> String:
	return input_edit.get_text()


func _on_Dialogue_pressed():
	emit_signal("dialogue_pressed")
