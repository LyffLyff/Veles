class_name ExtendedDirectory extends Reference

static func delete_file(var path : String) -> void:
	var dir : Directory = Directory.new()
	if dir.remove(path) != OK:
		Global.root.message("REMOVING FILE: " +  path,SaveData.MESSAGE_ERROR)


static func remove_folder_recursive(var DirPath : String):
	var directory = Directory.new()
	
	if directory.open(DirPath) == OK:
		
		# list directory content
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				remove_folder_recursive(DirPath + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		
		# removing current path
		directory.remove(DirPath)
	else:
		Global.root.message("REMOVING DIRECTORY: " +  DirPath,SaveData.MESSAGE_ERROR)


static func open_directory(var dir : String) ->void:
	if OS.shell_open(dir) != OK:
		Global.root.message("OPENING SONG DIRECTORY: " +  dir,SaveData.MESSAGE_ERROR)


static func clear_folder(var folder : String) -> void:
	var dir : Directory = Directory.new()
	if dir.open(folder) == OK:
		if dir.list_dir_begin(true,true) == OK:
			while true:
				var file_to_delete : String = dir.get_next()
				if file_to_delete != "":
					if dir.remove(file_to_delete) != OK:
						Global.root.message("REMOVING FILE: " +  file_to_delete,SaveData.MESSAGE_ERROR)
				else:
					break;
