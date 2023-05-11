class_name Tags extends Reference

signal cover_edited


static func get_text_tags(var path : String, var flags : PoolIntArray) -> PoolStringArray:
	return Tagging.new().get_multiple_tags(path, flags)


static func get_multiple_text_tags(var paths : PoolStringArray, var flags : PoolIntArray) -> Array:
	return Tagging.new().get_multiple_text_tags(paths, flags)


static func get_artist(var path : String) -> String:
	return Tagging.new().get_single_tag(path, Enumerations.ARTIST)


static func get_title(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.get_single_tag(path, Enumerations.TITLE)


static func get_album(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.get_single_tag(path, Enumerations.ALBUM)


static func get_genre(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.get_single_tag(path, Enumerations.GENRE)


static func get_song_rating(var path : String) -> String:
	var x : Tagging = Tagging.new()
	var temp_rating = x.get_song_popularity(path)[0]
	if temp_rating != null:
		return str(temp_rating)
	return "0"


static func get_lyrics(var song_path : String) -> Array:
	# synched: [Verses, Timestamps in absolute milliSeconds]
	# unsynched: [Lyrics as single long String]
	var cpp = Tagging.new()
	return cpp.get_lyrics(song_path)


static func get_song_duration(var path : String) -> int:
	return AudioProperties.new().get_duration_seconds(path)


static func get_cover_description(var src_path : String) -> String:
	return Tagging.new().get_cover_description(src_path)


static func get_embedded_cover(var src_path : String, var cover_idx : int = 0) -> PoolByteArray:
	var x : Tagging = Tagging.new()
	return x.get_embedded_cover(src_path, cover_idx)


static func get_embedded_covers(var src_path : String) -> Array:
	return Tagging.new().get_embedded_covers(src_path)


static func copy_embedded_covers(var src_paths : PoolStringArray, var dst_paths : PoolStringArray, var cover_idx : int) -> PoolByteArray:
	return Tagging.new().copy_covers(src_paths, dst_paths, cover_idx)


static func set_artist(var data : String, var path : String) -> void:
	set_text_tag(Enumerations.ARTIST, data, path)


static func set_title(var data : String, var path : String) -> void:
	set_text_tag(Enumerations.TITLE, data, path)


static func set_album(var data : String, var path : String) -> void:
	set_text_tag(Enumerations.ALBUM, data, path)


static func set_genre(var data : String, var path : String) -> void:
	set_text_tag(Enumerations.GENRE, data, path)


static func set_comment(var data : String, var path : String) -> void:
	#New comment_edit using ID3v2 will be located at the end of the file 
	set_text_tag(Enumerations.COMMENT, data, path)


static func set_track_number(var track_number : String, var path : String) -> void:
	set_text_tag(Enumerations.TRACK_NUMBER, track_number, path)


static func set_release_year(var release_year : String, var path : String) -> void:
	set_text_tag(Enumerations.RELEASE_YEAR, release_year, path)


static func set_rating(var rating : int, var path : String) -> void:
	Tagging.new().set_song_popularity(path, rating, 1, "")


static func add_cover(var imagepath : String, var filepath : String, var mime_type : String) -> void:  
	# convert webp images to png if needed
	var temp_file : bool = false
	var temp_cover_path : String = "user://temp.png"
	if imagepath.get_extension() == "webp" and SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ConverWebPToPNG"):
		var png_data : PoolByteArray = ImageLoader.webp_to_png(SaveData.load_buffer(imagepath))
		var png_img = ImageLoader.create_image_from_data(png_data)
		if png_img is Image:
			temp_file = true
			mime_type = "image/png"
			png_img.save_png(temp_cover_path)
			imagepath = SongLists.rel_to_abs_path(temp_cover_path)
	
	Tagging.new().add_cover(filepath, imagepath, mime_type)
	
	# delete temporary files after being used
	if temp_file:
		Directory.new().remove(imagepath)
	
	Global.call_deferred("emit_signal", "covers_edited")


static func remove_cover(var src_path : String, var cover_idx : int) -> void:
	if !Tagging.new().remove_cover(src_path, cover_idx):
		Global.message("Removing Single Cover Failed", Enumerations.MESSAGE_ERROR, true)
	Global.call_deferred("emit_signal", "covers_edited")
	
	# removing cached cover from directory if it's the last one
	if cover_idx == 0:
		var main_idx : int = AllSongs.get_main_idx(src_path) 
		if main_idx != -1:
			var coverhash : String = AllSongs.get_song_coverhash(main_idx)
			if SongLists.new_cached_covers.has(coverhash):
				if SongLists.new_cached_covers[coverhash][0].size() == 1:
					Directory.new().remove(AllSongs.get_song_cover_path(main_idx))


static func remove_all_covers(var src_path : String) -> void:
	if !Tagging.new().remove_all_covers(src_path):
		Global.message("Removing All Covers Failed", Enumerations.MESSAGE_ERROR, true)
	Global.call_deferred("emit_signal", "covers_edited")


static func remove_tag(var src_path : String) -> void:
	Tagging.new().remove_tag(src_path)


static func set_text_tag(var flag : int, var data : String,var path : String) -> void:
	var x : Tagging = Tagging.new()
	x.set_tag(flag, data, path)


static func set_cover_description(var src_path : String, var new_description : String) -> void:
	Tagging.new().set_cover_description(src_path, new_description)


static func set_lyrics(var src_paths : PoolStringArray,var is_synched : bool, var verses : PoolStringArray, var timestamps_in_absolute_seconds : PoolRealArray) -> void:
	# timestamps MUST be in absolute milliseconds -> specification of the Frame
	# timestamps get converted to Milliseconds since Veles works with seconds
	var timestamps_in_absolute_milliseconds : PoolIntArray = []
	for i in timestamps_in_absolute_seconds:
		#converting the timestamps from seconds to milliseconds
		timestamps_in_absolute_milliseconds.push_back( int(i * 1000.0) )
	
	var x : Tagging = Tagging.new()
	for src_path in src_paths:
		x.set_lyrics(src_path, verses, timestamps_in_absolute_milliseconds, is_synched)


static func get_text_properties(var audio_filepath : String) -> Dictionary:
	var properties : Dictionary = Tagging.new().get_text_properties(audio_filepath)
	var temp_val : String = ""
	if audio_filepath.to_upper().ends_with("MP4") or audio_filepath.to_upper().ends_with("M4A"):
		for key in properties.keys():
			if key.length() == 3:
				#	# Re - insert Copyright Symbol
				temp_val = properties[key]
				properties.erase(key)
				key = "©" + key
				properties[key] = temp_val
	return properties


static func set_text_property(var new_value : String, var audio_filepath : String, var property_id : String) -> void:
	Tagging.new().set_text_properties(audio_filepath, [property_id], [new_value])

