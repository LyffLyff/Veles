extends HBoxContainer


#SIGNALS
signal DialoguePressed

#NODES
onready var InputLabel : Label = $InputLabel
onready var InputEdit : LineEdit = $InputEdit
onready var Dialogue : TextureButton = $Dialogue

#VARIABLES
export var InputeLabelText : String = ""
export var OpenMode : int = 0
export var FileType : String = ""
export var ShowGeneralFileDialogue : bool = false


func _ready():
	InputLabel.text = InputeLabelText
	if !ShowGeneralFileDialogue:
		Dialogue.hide()


func get_text() -> String:
	return InputEdit.get_text()


func OnDialoguePressed():
	emit_signal("DialoguePressed")
