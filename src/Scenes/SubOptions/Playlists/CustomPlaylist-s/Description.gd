extends VBoxContainer


#NODES
onready var DescriptionEdit : TextEdit = $ScrollContainer/Description
onready var Animations : AnimationPlayer = $DescriptionAnimations


#VARIABLES
var FilePath : String = ""
var IsExpanded : bool = false



func LoadDescription(var DescriptionFilePath : String) -> void:
	FilePath = DescriptionFilePath
	var DescriptionText = SaveData.load_data(FilePath)
	if DescriptionText != null:
		DescriptionEdit.set_text(DescriptionText)


func SaveDescription():
	#Creates Automatically the given File if used
	SaveData.save(FilePath, DescriptionEdit.get_text())


func OnExpandDescriptionPressed():
	if !IsExpanded:
		Animations.play("Expand")
	else:
		Animations.play_backwards("Expand")
	IsExpanded = !IsExpanded
