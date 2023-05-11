extends HBoxContainer

onready var file_edit : LineEdit = $LineEdit
onready var dialogue : TextureButton = $FileDialog 


func _ready() -> void:
	if dialogue.connect("pressed", Global.root,"load_general_file_dialogue",[
		file_edit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		UsedFilepaths.DESKTOP,
		[],
		true
	]):
		Global.message("CONNECTING DIALOGUE PRESSED SIGNAL",  Enumerations.MESSAGE_ERROR )
	var file_path : String = SettingsData.get_setting(
		get_parent().get_parent().setting_type_idx,
		get_parent().file_setting_key
		)
	file_edit.set_text(file_path)


func OnLineEditTextEntered(var new_text : String):
	# setting Caret Position to the exit_image_view of Path so the Filename is visible a not just the root folders
	file_edit.caret_position = file_edit.text.length()
	SettingsData.set_setting(
		get_parent().get_parent().setting_type_idx,
		get_parent().file_setting_key,
		new_text
	)


func _on_LineEdit_text_changed(var new_text : String):
	if !Directory.new().file_exists(new_text):
		new_text = ""
	OnLineEditTextEntered(new_text)
