extends Control


#NODES
onready var InfoVBox : VBoxContainer = $HBoxContainer/Sidebar/ScrollContainer/HBoxContainer/InfoVbox
onready var InfoTextSpace : RichTextLabel = $HBoxContainer/VBoxContainer/PanelContainer/InfoTextSpace


func _ready():
	InitInfos()


func InitInfos() -> void:
	var SubInfosCounter : int = 0
	for i  in InfoVBox.get_child_count():
		if InfoVBox.get_child(i) is VBoxContainer:
			InfoVBox.get_child(i).set("SubInfos",InfoTextSpace.infos.values()[SubInfosCounter].size())
			InfoVBox.get_child(i).set("SubInfoTitles",InfoTextSpace.infos.values()[SubInfosCounter].keys())
			if InfoVBox.get_child(i).connect("SubInfoPressed",InfoTextSpace,"SetInfoText",[SubInfosCounter]):
				Global.root.message("CANNOT connect Signal SubInfoPressed to InfoTextSpace's SetInfoText function",  SaveData.MESSAGE_ERROR )
			SubInfosCounter += 1


func OnInfoTextSpaceMetaClicked(var meta : String):
	meta = meta.replace("user://",OS.get_user_data_dir())
	var _err = OS.shell_open(str(meta))
