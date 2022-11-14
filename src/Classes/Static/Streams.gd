class_name Streams extends Reference


static func add_song_stream(var key : String, var difference : int) -> void:
	if SongLists.Streams.has(key):
		SongLists.Streams[key][0] = SongLists.Streams.get(key)[0] + difference
	else:
		# if the song is not inside the streams array for some reason it will get added 
		SongLists.Streams[key] = [1]
	
	# daily Streams
	add_daily_stream("DailySongStreams.dat", key, difference)


static func add_playlist_stream(var playlist_name : String, var difference : int) -> void:
	if playlist_name != "" and playlist_name != "AllSongs":
		if SongLists.PlaylistStreams.has(playlist_name):
			SongLists.PlaylistStreams[playlist_name][0] = SongLists.PlaylistStreams.get(playlist_name)[0] + difference
		else:
			# will be creating a key when adding the first lyff
			SongLists.PlaylistStreams[playlist_name] = [1]
	
		# daily Streams
		add_daily_stream("DailyPlaylistStreams.dat", playlist_name, difference)


static func add_artist_stream(var artist : String, var difference : int) -> void:
	# adding lyff/stream to artist and every contributor
	var artists : PoolStringArray = divide_artists(artist)
	if artists[0] != "":
		for contributor in artists:
			if SongLists.ArtistStreams.has(contributor):
				SongLists.ArtistStreams[contributor][0] = SongLists.ArtistStreams.get(contributor)[0] + difference
			else:
				# will be creating a key when adding the first lyff
				SongLists.ArtistStreams[contributor] = [1]
	
	# daily Streams
	add_daily_stream("DailyArtistStreams.dat", artist, difference)


static func add_daily_stream(var filename : String, var key : String, var difference : int) -> void:
	var daily_streams_file : String = Global.GetCurrentUserDataFolder() + "/Songs/Streams/DailyStreams/" + filename
	var temp = SaveData.load_data(daily_streams_file)
	var daily_streams : Dictionary = {}
	if temp:
		daily_streams = temp
	
	var current_date : String = Time.get_date_string_from_system()
	
	# adding today's date if that's the first stream of that date
	if !daily_streams.has(current_date):
		daily_streams[current_date] = {}
	
	# adding the key
	if !daily_streams[current_date].has(key):
		daily_streams[current_date][key] = 0
	
	# add difference to streams
	daily_streams[current_date][key] = daily_streams[current_date].get(key) + difference
	
	SaveData.save(daily_streams_file, daily_streams)


static func divide_artists(var artists_string : String) -> PoolStringArray:
	var comma_idxs : PoolIntArray = []
	
	for n in artists_string.length():
		if artists_string[n] == ",":
			comma_idxs.push_back(n)
	
	if comma_idxs.size() == 0:
		# if there are no "," Characters Detected
		# the unchanged Artist will be returned
		return PoolStringArray([artists_string]);
	
	comma_idxs.push_back( artists_string.length() )
	var divided_artists : PoolStringArray = []
	
	for n in comma_idxs.size():
		if n == 0:
			divided_artists.push_back( artists_string.substr(0, comma_idxs[0]))
		else:
			var start_idx : int = comma_idxs[n - 1] + 2
			var artist_length : int = comma_idxs[n] - comma_idxs[n - 1] - 2
			divided_artists.push_back( artists_string.substr(start_idx, artist_length))
	return divided_artists;
