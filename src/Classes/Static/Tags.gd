class_name Tags extends Reference


static func get_text_tags(var path : String,var flags : PoolIntArray) -> PoolStringArray:
	var x : Tagging = Tagging.new()
	return x.GetMultipleTags(path,flags)


static func get_artist(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetSingleTag(path,0)


static func get_title(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetSingleTag(path,1)


static func get_album(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetSingleTag(path,2)


static func get_genre(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetSingleTag(path,3)


static func get_lyrics(var song_path : String) -> Array:
	# synched: [Verses, Timestamps in absolute milliSeconds]
	# unsynched: [Lyrics as single long String]
	var cpp = Tagging.new()
	return cpp.GetLyrics(song_path)


static func get_song_duration(var path : String) -> int:
	var x : Tagging = Tagging.new()
	return x.GetSongDuration(path)


static func get_cover_description(var src_path : String) -> String:
	return Tagging.new().get_cover_description(src_path)


static func get_tag_type(var src_path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetTagType(src_path)


static func get_embedded_cover(var src_path : String) -> PoolByteArray:
	var x : Tagging = Tagging.new()
	return x.GetMusicCover(src_path)


static func get_embedded_covers(var src_path : String) -> Array:
	var x : Tagging = Tagging.new()
	return x.GetAllMusicCovers(src_path)


static func copy_embedded_covers(var src_paths : PoolStringArray, var dst_paths : PoolStringArray) -> PoolByteArray:
	var cpp = Tagging.new()
	return cpp.CopyAllCovers(src_paths, dst_paths)


static func set_artist(var data : String, var path : String) -> void:
	set_text_tag(0,data,path)


static func set_title(var data : String, var path : String) -> void:
	set_text_tag(1,data,path)


static func set_album(var data : String, var path : String) -> void:
	set_text_tag(2,data,path)


static func set_genre(var data : String, var path : String) -> void:
	set_text_tag(3,data,path)


static func set_comment(var data : String, var path : String) -> void:
	#New comment_edit using ID3v2 will be located at the end of the file 
	set_text_tag(4,data,path)


static func set_track_number(var track_number : String, var path : String) -> void:
	set_text_tag(6, track_number, path)


static func set_release_year(var release_year : String, var path : String) -> void:
	set_text_tag(5, release_year, path)


static func set_cover(var img_path : String, var song_path : String, var mime_type : String) -> void:
	var x : Tagging = Tagging.new()
	var _err = x.SetCover(img_path, song_path, mime_type)


static func set_text_tag(var flag : int, var data : String,var path : String) -> void:
	var x : Tagging = Tagging.new()
	x.SetTag(flag, data, path)


static func set_cover_description(var src_path : String, var new_description : String) -> void:
	Tagging.new().SetCoverDescription(src_path, new_description)


static func set_lyrics(var src_paths : PoolStringArray,var is_synched : bool, var verses : PoolStringArray, var timestamps_in_absolute_seconds : PoolRealArray) -> void:
	# timestamps MUST be in absolute milliseconds -> specification of the Frame
	# timestamps get converted to Milliseconds since Veles works with seconds
	var timestamps_in_absolute_milliseconds : PoolIntArray = []
	for i in timestamps_in_absolute_seconds:
		#converting the timestamps from seconds to milliseconds
		timestamps_in_absolute_milliseconds.push_back( int(i * 1000.0) )
	
	var x : Tagging = Tagging.new()
	for src_path in src_paths:
		x.SetLyrics(src_path, verses, timestamps_in_absolute_milliseconds, is_synched)

