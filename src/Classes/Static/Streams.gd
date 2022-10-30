extends Reference

class_name Streams


static func AddSongStream(var key : String, var difference : int) -> void:
	if SongLists.Streams.has(key):
		SongLists.Streams[key][0] = SongLists.Streams.get(key)[0] + difference
	else:
		#if the song is not inside the streams array for some reason it will get added 
		SongLists.Streams[key] = [1]
	
	#Daily Streams
	AddDailyStream("DailySongStreams.dat", key, difference)


static func AddPlaylistStream(var playlist_name : String, var difference : int) -> void:
	if playlist_name != "" and playlist_name != "AllSongs":
		if SongLists.PlaylistStreams.has(playlist_name):
			SongLists.PlaylistStreams[playlist_name][0] = SongLists.PlaylistStreams.get(playlist_name)[0] + difference
		else:
			#will be creating a key when adding the first lyff
			SongLists.PlaylistStreams[playlist_name] = [1]
	
		#Daily Streams
		AddDailyStream("DailyPlaylistStreams.dat", playlist_name, difference)


static func AddArtistStream(var artist : String, var difference : int) -> void:
	var Artists : PoolStringArray = DivideMultipleArtists(artist)
	#adding lyff/stream to artist and every contributor
	if Artists[0] != "":
		for contributor in Artists:
			if SongLists.ArtistStreams.has(contributor):
				SongLists.ArtistStreams[contributor][0] = SongLists.ArtistStreams.get(contributor)[0] + difference
			else:
				#will be creating a key when adding the first lyff
				SongLists.ArtistStreams[contributor] = [1]
	
	#Daily Streams
	AddDailyStream("DailyArtistStreams.dat", artist, difference)

static func AddDailyStream(var filename : String, var key : String, var difference : int) -> void:
	var DailyStreamsPath : String = Global.GetCurrentUserDataFolder() + "/Songs/Streams/DailyStreams/" + filename
	var Temp = SaveData.Load(DailyStreamsPath)
	var DailyStreams : Dictionary = {}
	if Temp:
		DailyStreams = Temp
	
	var TodaysDate : String = Time.get_date_string_from_system()
	
	#Adding today's date if that's the first stream of that date
	if !DailyStreams.has(TodaysDate):
		DailyStreams[TodaysDate] = {}
	
	#Adding the key
	if !DailyStreams[TodaysDate].has(key):
		DailyStreams[TodaysDate][key] = 0
	
	#Add difference to streams
	DailyStreams[TodaysDate][key] = DailyStreams[TodaysDate].get(key) + difference
	
	SaveData.Save(DailyStreamsPath, DailyStreams)


static func DivideMultipleArtists(var ArtistString : String) -> PoolStringArray:
	var CommaIdxs : PoolIntArray = []
	
	for n in ArtistString.length():
		if ArtistString[n] == ",":
			CommaIdxs.push_back(n)
	
	if CommaIdxs.size() == 0:
		#if there are no "," Characters Detected
		#the unchanged Artist will be returned
		return PoolStringArray([ArtistString]);
	
	CommaIdxs.push_back( ArtistString.length() )
	var Artists : PoolStringArray = []
	
	for n in CommaIdxs.size():
		if n == 0:
			Artists.push_back( ArtistString.substr( 0,CommaIdxs[0] ) )
		else:
			var StartIdx : int = CommaIdxs[n - 1] + 2
			var ArtistLength : int = CommaIdxs[n] - CommaIdxs[n - 1] - 2
			Artists.push_back( ArtistString.substr(StartIdx, ArtistLength ))
	return Artists;
