class_name CoverLoader extends Reference
# a class that is used to minimize the memory needed to have covers stored
# this is done by comparing every single covers data
# and looking if it is equal to any other cover

# defines how many bytes will be loaded an then compared to delete the duplicate covers
# higher values amount to the possibility of mistakely thinking two Covers are the some to almost 0
# lower values are faster, but could Display some files with the wrong Cover
# 256 -> very few mistakes -> 2 in 200
# 512 -> up to now none
const COVER_DUPLICATE_SAMPLE : int = 768


func NewSongCovers(var to_copy : PoolStringArray) -> void:
	if to_copy.size() > 0:
		var new_song_covers : Dictionary = copy_song_covers(to_copy)
		filter_duplicate_cover(new_song_covers)


func copy_song_covers(var to_copy : PoolStringArray) -> Dictionary:
	# copies the covers of the given paths of there is one
	# return all the songs where this procedure was successfull
	var dst_folder : String = Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/"
	var dst_coverpaths : PoolStringArray = []
	var coverhashes : PoolStringArray = []

	# creating destination Paths
	for n in to_copy.size():
		coverhashes.push_back(str(to_copy[n].hash())) 
		dst_coverpaths.push_back(dst_folder + coverhashes[n] + ".png")

	# copying and getting Successes
	var copy_results : PoolByteArray = Tags.copy_embedded_covers(to_copy, dst_coverpaths)
	
	# filtering Copied Covers -> Successful/Unsuccessful
	var copied_covers : PoolStringArray = []
	var successfull_copies : PoolStringArray = []
	for n in to_copy.size():
		if copy_results[n]:
			copied_covers.push_back(to_copy[n])
			successfull_copies.push_back(coverhashes[n])
	
	# returning paths of successfully copied Song Covers
	var successfull_hashes : Dictionary = {}
	
	for n in copied_covers.size():
		successfull_hashes[ successfull_copies[n] ] = copied_covers[n]
	
	return successfull_hashes;


func filter_duplicate_cover(var new_songs : Dictionary) -> void:
	# filtering the given paths of songs and only return the ones
	# where the cover is unique, compared to the other given paths 
	# and all the already existing covers
	# if this function finds a duplicate coverimage it will be deleted and the coverhash gets updated
	# NewSongs = {hash : path}
	var image_header : PoolByteArray = []
	var covers : Dictionary = {}
	var idxs_to_skip : Array = []
	
	# comparing with the New Covers
	for x in new_songs.size():
		image_header = SaveData.load_buffer(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + new_songs.keys()[x] + ".png",1024)
		for y in new_songs.size():
			if !idxs_to_skip.has(x):
				if x != y:
					if image_header ==  SaveData.load_buffer(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + new_songs.keys()[y] + ".png",1024):
						
						if covers.has(new_songs.keys()[x]):
							var value : PoolStringArray = covers.get(new_songs.keys()[x])
							value.push_back(new_songs.keys()[y])
							if covers.erase(new_songs.keys()[x]):
								covers[ new_songs.keys()[x] ] = value
						else:
							covers[ new_songs.keys()[x] ] = [ new_songs.keys()[y] ]
						
						# skips the Cover idx since its already marked as a duplicate 
						idxs_to_skip.push_back(y)
				if y >= new_songs.size() - 1 and !covers.has(new_songs.keys()[x]):
					# adds the Key of the totally unique cover with an empty array as value
					covers[ new_songs.keys()[x] ] = []
	
	# comparing with other Covers
	for x in covers.size():
		image_header = SaveData.load_buffer(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + covers.keys()[x] + ".png",1024)
		for y in SongLists.cached_covers.size():
			if image_header == SaveData.load_buffer(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + SongLists.cached_covers.keys()[y] + ".png",1024):
				if !covers.has(SongLists.cached_covers.keys()[y]):
					var temp : PoolStringArray =  covers.values()[x]
					temp.push_back( covers.keys()[x] ) 
					covers[  SongLists.cached_covers.keys()[y] ] = temp
					if !covers.erase(covers.keys()[x]):
						Global.root.message("COULD NOT ERASE HASH FROM COVER DICTIONARY: " + covers.keys()[x], SaveData.MESSAGE_ERROR)

	for x in covers.size():
		var unique_hash : String = covers.keys()[x]
		if !SongLists.cached_covers.has(unique_hash):
			SongLists.cached_covers[unique_hash] = ImageLoader.get_cover(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + unique_hash + ".png","",Vector2(70,70))
		for y in covers.values()[x].size():
			var temp = null
			var duplicate_hash : String = covers.values()[x][y]
			temp = new_songs.get(duplicate_hash)
			if temp:
				var path : String = temp
				AllSongs.set_coverhash(path, unique_hash)
			else:
				if !SongLists.cached_covers.erase(duplicate_hash):
					Global.root.message("COULD NOT DELETE COVER THAT WAS PREVIOUSLY IN THE COVERCACHE: " + duplicate_hash, SaveData.MESSAGE_ERROR)
			ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + duplicate_hash + ".png")


