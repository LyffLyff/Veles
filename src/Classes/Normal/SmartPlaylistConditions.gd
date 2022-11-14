class_name SmartPlaylistConditions extends Reference
# this class holds functions to check the set conditions of smart playlists


func is_longer_than(var song_path : String, var length_in_seconds : String) -> bool:
	# returns true if the given Song is Longer than the Given Duration
	return AllSongs.get_song_duration( AllSongs.get_main_idx( song_path ) ) >= int( length_in_seconds );


func is_shorter_than(var song_path : String, var length_in_seconds : String) -> bool:
	# returns true if the given Song is Shorter than the Given Duration
	return AllSongs.get_song_duration( AllSongs.get_main_idx( song_path ) ) <= int( length_in_seconds );


func genre(var song_path : String, var genre : String) -> bool:
	# returns true if the given Genre is equal to the Genre specified in the Songs Tag
	return Tags.get_genre( song_path ) == genre;


func album(var song_path : String, var album_title : String) -> bool:
	# returns true if the given album title is equal to the Album Title specified in the Songs Tag
	return Tags.get_album( song_path ) == album_title;


func includes_artist(var song_path : String, var artist : String) -> bool:
	return artist in AllSongs.get_song_artist( AllSongs.get_main_idx(song_path) );


func excludes_artist(var song_path : String, var artist : String) -> bool:
	# returns true if the Artist not in the String
	return !( artist in AllSongs.get_song_artist( AllSongs.get_main_idx(song_path) ) );


func includes_either_artist(var song_path : String, var artists : PoolStringArray) -> bool:
	# returns true if any of the given Artists is cited as Artist in the given Song
	var song_artists : String = AllSongs.get_song_artist( AllSongs.get_main_idx(song_path) )
	for artist in artists:
		if artist in song_artists:
			return true;
	return false;


func has_embedded_lyrics(var _song_path : String) -> bool:
	# returns true if the given Song has either UNSYNCHED/SYNCHED Lyrics
	return false;


func has_synched_lyrics(var _song_path : String) -> bool :
	return false;


func has_unsynched_lyrics(var _song_path : String) -> bool :
	return false;


func title_includes(var song_path : String, var search_phrase : String) -> bool:
	var TagTitle : String = Tags.new().get_title(song_path)
	return TagTitle.find( search_phrase ) != -1 


func song_rating_is(var song_path : String, var rating_out_of_10 : String) -> bool:
	#Return if the Song Rating out of 10 given is the same as the Songs Rating
	var song_rating = Tagging.new().GetSongPopularity(song_path)[0]
	if typeof(song_rating) != TYPE_INT:
		return false
	return song_rating == int(rating_out_of_10)


func song_rating_is_greater(var song_path : String, var rating_out_of_10 : String) -> bool:
	var song_rating = Tagging.new().GetSongPopularity(song_path)[0]
	if typeof(song_rating) != TYPE_INT:
		return false
	return song_rating > int(rating_out_of_10)


func song_rating_is_lesser(var song_path : String, var rating_out_of_10 : String) -> bool:
	var song_rating = Tagging.new().GetSongPopularity(song_path)[0]
	if typeof(song_rating) != TYPE_INT:
		return false
	return song_rating < int(rating_out_of_10)


func has_cover(var _song_path : String) -> bool:
	return false


func has_same_cover_as(var _song_path : String, var _cover_src : String) -> bool:
	return false
