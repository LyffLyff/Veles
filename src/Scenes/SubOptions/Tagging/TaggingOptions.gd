extends VBoxContainer

signal files_selected
signal directory_selected
signal refresh_directory
signal remove_tag
signal to_parent_directory


func _on_OpenDirectory_pressed():
	Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_DIR,
		FileDialog.ACCESS_FILESYSTEM,
		"on_directory_selected",
		[],
		UsedFilepaths.TAG_PATH,
		Global.supported_tag_extensions,
		true,
		"Select Directory"
	)


func _on_OpenFiles_pressed():
	Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"on_files_selected",
		[],
		UsedFilepaths.TAG_PATH,
		Global.supported_tag_extensions,
		false,
		"Select File/s"
	)


func on_directory_selected(var dir_path : String) -> void:
	self.emit_signal("directory_selected", dir_path)


func on_files_selected(var selected_files : PoolStringArray) -> void:
	self.emit_signal("files_selected", selected_files)


func _on_RefreshFolder_pressed():
	self.emit_signal("refresh_directory")


func _on_RemoveTag_pressed():
	self.emit_signal("remove_tag")


func _on_ToParentDirectory_pressed():
	self.emit_signal("to_parent_directory")

