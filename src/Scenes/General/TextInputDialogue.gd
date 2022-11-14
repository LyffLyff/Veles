extends "res://src/Scenes/General/StdPopupBackground.gd"


#SIGNALS
signal TextSave

#NODES
onready var TopicLabel : Label = $PanelContainer/HBoxContainer/VBoxContainer/TopicLabel
onready var InputEdit : LineEdit = $PanelContainer/HBoxContainer/VBoxContainer/Input/InputEdit
onready var DialogueButton : TextureButton = $PanelContainer/HBoxContainer/VBoxContainer/Input/FileDialogue


func SetTopic(var Topic : String) -> void:
	TopicLabel.set_text(Topic)


func InitDialogueButton(var OpenMode : int = FileDialog.MODE_OPEN_FILE, var FileAccess : int = FileDialog.ACCESS_FILESYSTEM, FileType : String = "Cover", FileTypeFilters : PoolStringArray = []) -> void:
	DialogueButton.show()
	var _err = DialogueButton.connect("pressed",Global.root,"load_general_file_dialogue",[
		InputEdit,
		OpenMode,
		FileAccess,
		"set_text",
		[],
		FileType,
		FileTypeFilters,
		true
	])


func OnClosePressed():
	ExitPopup()


func OnSavePressed():
	emit_signal("TextSave", InputEdit.get_text() )
	ExitPopup()
