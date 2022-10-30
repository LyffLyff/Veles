extends VBoxContainer


#NODES
onready var Title : Label = $Title
onready var Info : Label = $Info


func InitInfoSpace(var TitleText: String, var InfoText : String) -> void:
	Title.set_deferred("text", TitleText + ":")
	Info.set_deferred("text", InfoText)
