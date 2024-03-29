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
		if SongLists.playlist_streams.has(playlist_name):
			SongLists.playlist_streams[playlist_name][0] = SongLists.playlist_streams.get(playlist_name)[0] + difference
		else:
			# will be creating a key when adding the first lyff
			SongLists.playlist_streams[playlist_name] = [1]
	
		# daily Streams
		add_daily_stream("DailyPlaylistStreams.dat", playlist_name, difference)


static func add_artist_stream(var artist : String, var difference : int) -> void:
	# adding lyff/stream to artist and every contributor
	var artists : PoolStringArray = Artist.divide_artists(artist)
	if artists[0] != "":
		for contributor in artists:
			if SongLists.artist_streams.has(contributor):
				SongLists.artist_streams[contributor][0] = SongLists.artist_streams.get(contributor)[0] + difference
			else:
				# will be creating a key when adding the first lyff
				SongLists.artist_streams[contributor] = [1]
	
	# daily Streams
	add_daily_stream("DailyArtistStreams.dat", artist, difference)


static func add_daily_stream(var filename : String, var key : String, var difference : int) -> void:
	var daily_streams_file : String = Global.get_current_user_data_folder() + "/Songs/Streams/DailyStreams/" + filename
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

