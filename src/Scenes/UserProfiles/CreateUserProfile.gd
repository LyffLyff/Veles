extends PanelContainer

#NODES
onready var ProfileImgSelection : HBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/SelectProfileImg
onready var Username : LineEdit = $PanelContainer/HBoxContainer/VBoxContainer/UsernameSelect


func _ready():
	var _err = ProfileImgSelection.connect("DialoguePressed",self,"LoadDialogue")


func LoadDialogue() -> void:
	var _dialog = Global.root.OpenGeneralFileDialogue(
		ProfileImgSelection.InputEdit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		"Cover",
		Global.SupportedImgFormats,
		true
	)


func OnSaveProfile() -> void:
	var dir : Directory = Directory.new()
	var CoverSrc : String = ProfileImgSelection.InputEdit.get_text()
	if dir.file_exists(CoverSrc):
		dir.copy( 
			CoverSrc,
			"user://GlobalSettings/UserImages/" + Username.get_text() + ".png"
		)
		
	Global.NewUserProfile(Username.get_text())
	Global.UserProfiles.push_back(Username.get_text())
	self.queue_free()
