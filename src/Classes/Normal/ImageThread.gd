class_name CoverLoader extends Reference
# a class that is used to minimize the memory needed to have covers stored
# this is done by comparing every single covers data
# and looking if it is equal to any other cover

# defines how many bytes will be loaded an then compared to delete the duplicate covers
# higher values amount to the possibility of mistakely thinking two Covers are the some to almost 0
# lower values are faster, but could Display some files with the wrong Cover
# 256 -> very few mistakes -> 2 in 200
# 512 -> up to now none
const COVER_DUPLICATE_SAMPLE : int = 1024


func new_song_covers(var to_copy : PoolStringArray) -> void:
	if to_copy.size() > 0:
		filter_duplicate_covers(copy_song_covers(to_copy))
		SongLists.init_cached_covers()


func copy_song_covers(var to_copy : PoolStringArray) -> Dictionary:
	# copies the covers of the given paths of there is one
	# return all the songs where this procedure was successfull
	var dst_folder : String = Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/"
	var dst_coverpaths : PoolStringArray = []
	var cover_files : Dictionary = {}
	var unique_filename : String = ""

	# creating destination Paths
	for n in to_copy.size():
		unique_filename = generate_unique_filename(FormatChecker.get_img_extension_from_embedded_cover(to_copy[n]))
		dst_coverpaths.push_back(dst_folder + unique_filename)
		AllSongs.set_coverhash(to_copy[n], unique_filename)
   
	# copying and getting successes
	var copy_results : PoolByteArray = Tags.new().copy_embedded_covers(to_copy, dst_coverpaths, 0)
	# filtering Copied Covers -> Successful/Unsuccessful
	var copied_covers : PoolStringArray = []
	for n in to_copy.size():
		if copy_results[n]:
			cover_files[dst_coverpaths[n].get_file()] = [[to_copy[n]], null]
	return cover_files;


func filter_duplicate_covers(var new_songs : Dictionary) -> void:
	# input -> paths of covers that were copied
	# filtering the given paths of songs and only return the ones
	# where the cover is unique, compared to the other given paths 
	# and all the already existing covers
	# if this function finds a duplicate coverimage it will be deleted and the coverhash gets updated
	# new_songs = {hash : path}
	var image_header : PoolByteArray = []
	var covers : Dictionary = {}
	var cover_path_x : String = ""
	var cover_path_y : String = ""
	var idxs_to_skip : Array = []
	var duplicates : PoolStringArray = []
	# comparing with the New Covers
	for x in new_songs.size():
		cover_path_x = Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + new_songs.keys()[x]
		image_header = SaveData.load_buffer(cover_path_x, COVER_DUPLICATE_SAMPLE)
		for y in new_songs.size():
			if !idxs_to_skip.has(x):
				if x != y:
					cover_path_y = Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + new_songs.keys()[y]
					if image_header == SaveData.load_buffer(cover_path_y, COVER_DUPLICATE_SAMPLE):
						var tkey : String = new_songs.keys()[y]
						new_songs.values()[x][0].append_array(new_songs.get(tkey)[0])
						
						# replacing the cover file identifier in the song dictionary
						set_cover_identifiers(new_songs.values()[y][0], new_songs.keys()[x])
						
						#adding to duplicates
						duplicates.push_back(tkey)
						
						# skips the Cover idx since its already marked as a duplicate 
						idxs_to_skip.push_back(y)
	
	new_songs = delete_duplicate_covers(duplicates, new_songs)
	duplicates = []
	var is_in_cached : bool = false
	
	# comparing with other Covers
	for x in new_songs.size():
		cover_path_x = Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + new_songs.keys()[x]
		image_header = SaveData.load_buffer(cover_path_x, COVER_DUPLICATE_SAMPLE)
		is_in_cached = false
		for y in SongLists.new_cached_covers.size():
			cover_path_y = Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + SongLists.new_cached_covers.keys()[y]
			if image_header == SaveData.load_buffer(cover_path_y, COVER_DUPLICATE_SAMPLE):
				is_in_cached = true
				SongLists.new_cached_covers.values()[y][0].append_array(new_songs.values()[x][0])
				set_cover_identifiers(new_songs.values()[x][0], SongLists.new_cached_covers.keys()[y])
				duplicates.push_back(new_songs.values()[x][0])
		if !is_in_cached:
			SongLists.new_cached_covers[new_songs.keys()[x]] = new_songs.values()[x]
			set_cover_identifiers(new_songs.values()[x][0], new_songs.keys()[x])
	
	new_songs = delete_duplicate_covers(duplicates, new_songs)
	duplicates = []
	
	delete_unused_cover_identifiers(new_songs)


func generate_unique_filename(var extension : String = "") -> String:
	randomize()
	var random_num : int = randi() % 1_000_000
	return str(OS.get_unix_time() - random_num) + extension


func delete_duplicate_covers(var duplicates : PoolStringArray, var new_songs : Dictionary) -> Dictionary:
	var dir : Directory = Directory.new()
	for i in duplicates:
		var _err = dir.remove(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + i)
		_err = new_songs.erase(i)
	return new_songs


func set_cover_identifiers(var paths : PoolStringArray, var unique_identifier : String) -> void:
	for path in paths:
		AllSongs.set_coverhash(path, unique_identifier)


func delete_unused_cover_identifiers(var new_song_covers : Dictionary) -> void:
	# since somethings may go wrong or happen outside of Veles there needs to
	# be a check to delete unused cover identifiers, so it does not have any useless space
	var dir : Directory = Directory.new()
	for key in SongLists.new_cached_covers:
		if SongLists.new_cached_covers.get(key)[0].size() == 0:
			var _err = SongLists.new_cached_covers.erase(key)
			if dir.remove(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + key) != OK:
				Global.message("COULD NOT REMOVE UNUSED COVER", Enumerations.MESSAGE_WARNING)
	
	for key in new_song_covers:
		if !SongLists.new_cached_covers.has(key):
			if dir.remove(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + key) != OK:
				Global.message("COULD NOT REMOVE UNUSED COVER", Enumerations.MESSAGE_WARNING)
