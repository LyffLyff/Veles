class_name SaveData extends Reference


static func save(var filename : String, var data) -> void:
	var file : File = File.new()
	if file.open(filename, File.WRITE) == OK:
		file.store_var(data)
		file.close()


static func load_data(var filename : String):
	var file : File = File.new()
	if file.open(filename,File.READ) == OK:
		var data = file.get_var()
		file.close()
		return data
	else:
		if Global.root and Global.root.has_method("message"):
			Global.message("OPENING FILE TO LOAD VARIANT: " + filename, Enumerations.MESSAGE_ERROR, false)
	return null


static func save_as_text(var filename : String, var data : String) -> void:
	var file : File = File.new()
	if file.open(filename,File.WRITE) == OK:
		file.store_string(data)
		file.close()


static func load_as_text(var filename : String) -> String:
	var file : File = File.new()
	var err = file.open(filename,File.READ)
	if err == OK:
		var data = file.get_as_text()
		file.close()
		if data != "":
			return data
	else:
		if Global.root:
			Global.message("OPENING FILE TO LOAD AS TEXT: " + str(err) + " :" + filename, Enumerations.MESSAGE_ERROR, false)
	return ""


static func load_buffer(var path : String, var custom_length : int = -1) -> PoolByteArray:
	# loads and images data as a PoolByteArray and returns it
	# length_flag = -1 then all data will be loaded else just the the header
	var file : File = File.new()
	if file.open(path,File.READ) == OK:
		var data
		if custom_length != -1:
			data = file.get_buffer(custom_length)
		else:
			data = file.get_buffer(file.get_len())
		file.close()
		return data
	else:
		# returns empty PoolByteArray if the data could not be loaded
		return PoolByteArray()


static func save_buffer(var path : String, var buffer : PoolByteArray) -> void:
	var file : File = File.new()
	if file.open(path,File.READ) == OK:
		file.store_buffer(buffer)
		file.close()


static func push_key_and_save(var filename : String, var key : String, var array_idx : int, var edit_flag : bool, var push_data) -> bool:
	# can Edit Data in specificly formatted Dictionary
	# value -> Array
	# edit Flag defines if the Value Array will be edited or Replaced with the given data
	var data = load_data(filename);
	if !data:
		data = {}
	if !data.has(key):
		data[key] = []
	if edit_flag:
		var Arr : Array = data.get(key)
		Arr.insert(array_idx, push_data)
		data[key] = Arr
	else:
		# if this type is chosen the PushData needs to be of type Array
		data[key] = push_data
	save(filename, data)
	return true;


static func erase_key_from_file(var filename : String, var key : String) -> void:
	var data = load_data(filename);
	if !data or !data.has(key):
		return
	data.erase(key)
	save(filename, data)


static func get_key_from_file(var filename : String, var key : String, var array_idx : int):
	var data = load_data(filename)
	if !data or !data.has(key):
		return null
	if data[key].size() > array_idx:
		return data[key][array_idx]


static func replace_key_from_file(var filename : String, var old_key : String, var new_key : String) -> void:
	var data = load_data(filename)
	if !data or !data.has(old_key):
		return
	var value = data.get(old_key)
	data.erase(old_key)
	data[new_key] = value
	save(filename, data)


static func log_message(var message : String, var message_type : int) -> void:
	# appends a given message to the Log file.
	# message start defines the type of message given
	
	var message_start : String = ""
	var path : String = Global.get_current_user_data_folder() + "/Settings/CoreSettings/Logs.txt"
	var file : File = File.new()
	
	# READ_WRITE will not create a file
	# WRITE_READ, creates a file, but seek_end will not work
	match file.open(path, File.READ_WRITE):
		OK:
			pass;
		ERR_FILE_NOT_FOUND:
			#Creates the file and then continues
			var _err = file.open(path, File.WRITE)
			file.close()
			if file.open(path, File.READ_WRITE) != OK:
				return
		_:
			# returns on all errors that are not ERR_FILE_NOT_FOUND
			return
	
	file.seek_end()
	if file.get_len() != 0:
		file.store_string("\n")
	
	match message_type:
		Enumerations.MESSAGE_ERROR:
			message_start = "MESSAGE_ERROR"
		Enumerations.MESSAGE_WARNING:
			message_start = "MESSAGE_WARNING"
		Enumerations.MESSAGE_SUCCESS:
			message_start = "MESSAGE_SUCCESS"
		Enumerations.MESSAGE_NOTICE:
			message_start = "MESSAGE_NOTICE"
	
	var message_timestamp : String = "[" + Time.get_datetime_string_from_system() + "]"
	
	file.store_string(message_timestamp + " " + message_start + ": " + message)
	file.close()


static func load_config_file(var path : String) -> ConfigFile:
	var config : ConfigFile = ConfigFile.new()
	var _err = config.load(path)
	return config


static func get_config_value(var section : String, var key : String):
	var config : ConfigFile = load_config_file("user://override.cfg" )
	if !config.has_section(section):
		return null
	if !config.has_section_key(section, key):
		return null
	
	return config.get_value(section, key)


static func set_config_value(var section : String, var key : String, var new_value) -> void:
	var config : ConfigFile = load_config_file("user://override.cfg" )
	config.set_value(section, key, new_value)
	var _err = config.save("user://override.cfg")
