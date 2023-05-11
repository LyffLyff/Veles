class_name ExtendedDirectory extends Reference

static func delete_file(var path : String) -> void:
	var dir : Directory = Directory.new()
	if dir.remove(path) != OK:
		Global.message("REMOVING FILE: " +  path,Enumerations.MESSAGE_ERROR)


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
		Global.message("REMOVING DIRECTORY: " +  DirPath,Enumerations.MESSAGE_ERROR)


static func open_directory(var dir : String) ->void:
	if OS.shell_open(dir) != OK:
		Global.message("OPENING SONG DIRECTORY: " +  dir,Enumerations.MESSAGE_ERROR)


static func clear_folder(var folder : String) -> void:
	var dir : Directory = Directory.new()
	if dir.open(folder) == OK:
		if dir.list_dir_begin(true,true) == OK:
			while true:
				var file_to_delete : String = dir.get_next()
				if file_to_delete != "":
					if dir.remove(file_to_delete) != OK:
						Global.message("REMOVING FILE: " +  file_to_delete,Enumerations.MESSAGE_ERROR)
				else:
					break;


static func get_files_in_directory(var path : String, var type : PoolStringArray  = [], var recursive : bool = false) -> PoolStringArray:
	var files : PoolStringArray = []
	var dir : Directory = Directory.new()
	if dir.open(path) != OK or dir.list_dir_begin(true, true) != OK:
		return files

	var next = dir.get_next()
	while !next.empty():
			if dir.current_is_dir():
				if recursive:
					files += get_files_in_directory("%s/%s" % [dir.get_current_dir(), next], type, recursive)
			else:
				if type.empty() or next.get_extension().to_upper() in type:
					files.append("%s/%s" % [dir.get_current_dir(), next])
			next = dir.get_next()

	dir.list_dir_end()
	return files


static func is_folder_within_directory(var search_directory_path : String, var proposed_directory_path : String, recursive : bool) -> bool:
	# checks if a folder is a subfolder of another one -> for adding folders recursively
	
	proposed_directory_path = proposed_directory_path.rstrip("/")
	
	var is_within : bool = false
	var dir : Directory = Directory.new()
	var temp_subfolder : String = ""
	
	if dir.open(search_directory_path) != OK or dir.list_dir_begin(true, true) != OK:
		return true

	var next = dir.get_next()
	while !next.empty():
			if dir.current_is_dir():
				temp_subfolder = "%s/%s" % [dir.get_current_dir(), next]
				if proposed_directory_path == temp_subfolder:
					is_within = true
					break
				
				if recursive:
					if is_folder_within_directory(temp_subfolder, proposed_directory_path, recursive):
						is_within = true
						break
					
			next = dir.get_next()

	dir.list_dir_end()
	return is_within


static func get_parent_directory(var directory_path : String) -> String:
	var dir : Directory = Directory.new()
	if dir.open(directory_path) != OK:
		return directory_path
	return dir.get_current_dir().get_base_dir()
