extends Reference

class_name SaveData

#ENUMS
enum {
	MESSAGE_ERROR,
	MESSAGE_WARNING,
	MESSAGE_SUCCESS,
	MESSAGE_NOTICE
}


static func Save(var filename : String, var data) -> void:
	var file : File = File.new()
	if file.open(filename,File.WRITE) == OK:
		file.store_var(data)
		file.close()


static func Load(var filename : String):
	var file : File = File.new()
	if file.open(filename,File.READ) == OK:
		var data = file.get_var()
		file.close()
		return data
	else:
		if Global.root:
			Global.root.Message("OPENING FILE TO LOAD VARIANT: " + filename,MESSAGE_ERROR, false, Color() )
	return null


static func SaveAsText(var filename : String, var data : String) -> void:
	var file : File = File.new()
	if file.open(filename,File.WRITE) == OK:
		file.store_string(data)
		file.close()


static func LoadAsText(var filename : String) -> String:
	var file : File = File.new()
	var err = file.open(filename,File.READ)
	if err == OK:
		var data = file.get_as_text()
		file.close()
		if data != "":
			return data
	else:
		if Global.root:
			Global.root.Message("OPENING FILE TO LOAD AS TEXT: " + str(err) + " :" + filename,MESSAGE_ERROR, false, Color() )
	return ""


#loads and images data as a PoolByteArray and returns it
#length_flag = -1 then all data will be loaded else just the the header
static func LoadBuffer(var path : String, var Length : int = -1) -> PoolByteArray:
	var file : File = File.new()
	if file.open(path,File.READ) == OK:
		var data
		if Length != -1:
			data = file.get_buffer(Length)
		else:
			data = file.get_buffer(file.get_len())
		file.close()
		return data
	else:
		#returns empty PoolByteArray if the data could not be loaded
		return PoolByteArray()


static func PushDictKeyAndSave(var filename : String,var Key : String,var ArrIdx : int,var EditFlag : bool,var PushData) -> bool:
	#Can Edit Data in specificly formatted Dictionary
	#Value -> Array
	#Edit Flag defines if the Value Array will be edited or Replaced with the given data
	var data = Load(filename);
	if !data:
		data = {}
	if !data.has(Key):
		data[Key] = []
	if EditFlag:
		var Arr : Array = data.get(Key)
		Arr.insert(ArrIdx,PushData)
		data[Key] = Arr
	else:
		#if this type is chosen the PushData needs to be of type Array
		data[Key] = PushData
	Save(filename, data)
	return true;


static func EraseKeyFromFile(var filename : String,var Key : String) -> void:
	var data = Load(filename);
	if !data or !data.has(Key):
		return
	data.erase(Key)
	Save(filename, data)


static func GetDictKeyFromFile(var filename : String,var Key : String,var ArrIdx : int):
	var data = Load(filename);
	if !data or !data.has(Key):
		return null
	if data[Key].size() > ArrIdx:
		return data[Key][ArrIdx]


static func LogMessage(var message : String, var message_type : int) -> void:
	#Appends a given message to the Log file.
	#Message start defines the type of message given
	var message_start : String = ""
	var path : String = Global.GetCurrentUserDataFolder() + "/Settings/CoreSettings/Logs.txt"
	var file : File = File.new()
	
	#READ_WRITE will not create a file
	#WRITE_READ, creates aa file, but seek_end will not work
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
			#Returns on all errors that are not ERR_FILE_NOT_FOUND
			return
	
	file.seek_end()
	if file.get_len() != 0:
		file.store_string("\n")
	
	match message_type:
		MESSAGE_ERROR:
			message_start = "MESSAGE_ERROR"
		MESSAGE_WARNING:
			message_start = "MESSAGE_WARNING"
		MESSAGE_SUCCESS:
			message_start = "MESSAGE_SUCCESS"
		MESSAGE_NOTICE:
			message_start = "MESSAGE_NOTICE"
	
	var message_timestamp : String = "[" + Time.get_datetime_string_from_system() + "]"
	
	file.store_string(message_timestamp + " " + message_start + ": " + message)
	file.close()


static func LoadConfigFile(var path : String) -> ConfigFile:
	var config : ConfigFile = ConfigFile.new()
	var _err = config.load(path)
	return config


static func GetConfigValue(var Section : String, var Key : String):
	var config : ConfigFile = LoadConfigFile("user://override.cfg" )
	if !config.has_section(Section):
		return null
	if !config.has_section_key(Section,Key):
		return null
	
	return config.get_value(Section, Key)


static func SetConfigValue(var Section : String, var Key : String, var NewValue) -> void:
	var config : ConfigFile = LoadConfigFile("user://override.cfg" )
	config.set_value(Section,Key,NewValue)
	var _err = config.save("user://override.cfg")
