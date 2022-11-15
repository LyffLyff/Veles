extends HBoxContainer

#NODES
onready var FileEdit : LineEdit = $LineEdit
onready var Dialogue : TextureButton = $FileDialog 
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)


func _ready() -> void:
	if Dialogue.connect("pressed", root,"load_general_file_dialogue",[FileEdit, FileDialog.MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, "set_text", [], "Image", [], true]):
		Global.root.message("CONNECTING DIALOGUE PRESSED SIGNAL",  SaveData.MESSAGE_ERROR )
	var FilePath : String = SettingsData.get_setting(
		get_parent().get_parent().setting_type_idx,
		get_parent().FileSettingKey
		)
	FileEdit.set_text( FilePath )


func OnLineEditTextEntered(var new_text : String):
	#Setting Caret Position to the end of Path so the Filename is visible a not just the root folders
	FileEdit.caret_position = FileEdit.text.length()
	SettingsData.set_setting(
		get_parent().get_parent().setting_type_idx,
		get_parent().FileSettingKey,
		new_text
	)


func _on_LineEdit_text_changed(var new_text : String):
	if !Directory.new().file_exists(new_text):
		new_text = ""
	OnLineEditTextEntered(new_text)
