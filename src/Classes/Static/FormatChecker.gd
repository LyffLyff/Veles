class_name FormatChecker extends Reference
# a class that has functions to identify image and audio files,
# using their extension and/or raw data

static func encode_header(var data : PoolByteArray) -> String:
	data.resize(256)
	return data.hex_encode()


static func identify_image_file(var data : String) -> int:
	# encodes the first 256 Bytes as hex and searches for the supported formats
	# even though all of them are saved as .png files this is just for simplicity
	# in reality the could be anything
	# WEBP -> 57454250
	# PNG  -> 504e47
	# JPEG -> 6a706567
	# JPG  -> 4a5047
	# JPEG start Code -> ff8dff
	# JFIF -> 4a464946
	# Exif -> 45786966
	var image_codes : PoolStringArray = [
		"57454250",
		"504e47",
		"6a706567","ffd8ff","4a5047","4a464946","45786966","ff8dff"
	]
	
	# code: 0 = JPEG
	# code: 1 = PNG
	# code: 2 = Webp
	# save the return value of the coressponding Hex Code in the image_codes Array
	var return_codes : PoolIntArray = [2,1,0,0,0,0,0,0]
	
	for idx in image_codes.size():
		if image_codes[idx] in data:
			return return_codes[idx];
	
	# corrupted, unidentifiable or unsupported file format
	return -1;


static func get_music_file_extension(var song_path : String) -> String:
	match get_music_format_from_data( encode_header( SaveData.load_buffer( song_path, 1024 ))):
		0:
			return ".ogg"
		1:
			return ".mp3"
		2:
			return ".wav"
		3:
			return ".flac"
		4:
			return ".opus"
		5:
			return ".m4a"
		_:
			return "Unidentifiable"


static func get_music_format_from_data(var max_check_data : String) -> int:
	# returns the actual Format by checking the Hex Encoded Data for Certain File Signatures
	# ISO [-1]:
	#			isomp4l    -> 69 73 6f 36 6D 70 34 31
	# MP3  [1]:
	#			ID3    -> 49 44 33
	#			APIC   -> 41 50 49 43
	# WAV [2]:
	#			WAVE   -> 57 41 56 45
	#			RIFF   -> 52 49 46 46
	# Ogg OPUS [4]:
	#			Opus   -> 4F 70 75 73
	# Ogg Vorbis [0]:
	#			vorbis -> 76 6f 72 62 69 73
	#			Ogg	   -> 4f 67 67
	var unique_id_bytes : PoolStringArray = ["69736f366d703431","494433","41504943","766f72626973","4f6767","57415645","52494646"]
	var return_codes : PoolIntArray = [-1,1,1,0,0,2,2,3,3]
	var check_sizes : PoolIntArray = [16,64,128,1024]
	var data_sample : String = ""
	
	for SampleSizeIdx in check_sizes.size():
		# 1 Byte is equal to 2 characters in the String, thats why the * 2
		if SampleSizeIdx > 0:
			data_sample = max_check_data.substr(check_sizes[SampleSizeIdx - 1], check_sizes[SampleSizeIdx] * 2)
		else:
			data_sample = max_check_data.substr(0, check_sizes[SampleSizeIdx] * 2)
		for idx in unique_id_bytes.size():
			if unique_id_bytes[idx] in data_sample:
				return return_codes[idx];
	
	# corrupted, unidentifiable or unsupported file format
	return -1;


static func extended_music_formats(var data : String) -> String:
	# returning the index of the last bytes that were not part of the audio
	# Oother Formats#
	# ISO [3]:
	# If this is the case checks the whole file for start
	#			iso    -> 69 73 6f
	#			ISO    -> 49 53 4F
	var extra_codes : PoolStringArray = ["69736f","49534F"]
	for idx in extra_codes.size():
		var x : int = data.find(extra_codes[idx])
		if x != -1:
			return data.substr(x,data.length()-1)
	
	# returns error not found
	return ""


static func get_music_filename_extension(var path : String) -> int:
	if path.ends_with(".ogg"):
		return 0
	elif path.ends_with(".mp3"):
		return 1
	elif path.ends_with(".wav"):
		return 2
	elif path.ends_with(".flac"):
		return 3
	elif path.ends_with(".opus"):
		return 4
	elif path.ends_with(".m4a"):
		return 5
	return -1
