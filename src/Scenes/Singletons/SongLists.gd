extends Node
# the songlist singleton holds the main lists and function to handle and edit
# all songs and playlist within Veles

const std_userdata_paths : Array = [
	"user://GlobalSettings/StdUserdata/Folders.dat",
	"user://GlobalSettings/StdUserdata/LastSong.dat",
	"user://GlobalSettings/StdUserdata/LastPlaylist.dat",
	"user://GlobalSettings/StdUserdata/NormalPlaylists.dat",
	"user://GlobalSettings/StdUserdata/SongStreams.dat",
	"user://GlobalSettings/StdUserdata/PlaylistStreams.dat",
	"user://GlobalSettings/StdUserdata/ArtistStreams.dat",
	"user://GlobalSettings/StdUserdata/Settings.dat",
	"user://GlobalSettings/StdUserdata/SonqQueue.dat",
	"user://GlobalSettings/StdUserdata/PlaylistMetadata.dat",
	"user://GlobalSettings/StdUserdata/AllSongs.dat",
	"user://GlobalSettings/StdUserdata/CoverCache.dat",
	"user://GlobalSettings/StdUserdata/Artists.dat",
	"user://GlobalSettings/StdUserdata/SmartPlaylists.dat",
	"user://GlobalSettings/StdUserdata/TempSmartPlaylist.dat",
	"user://GlobalSettings/StdUserdata/AudioEffects.dat",
	"user://GlobalSettings/StdUserdata/DownloadQueue.dat",
	"user://GlobalSettings/AppStats/UsageTime.dat"
]
const file_paths : Array = [
	"user://Users/USERNAME/Settings/CoreSettings/Folders.dat",
	"user://Users/USERNAME/Settings/CoreSettings/LastSong.dat",
	"user://Users/USERNAME/Settings/CoreSettings/LastPlaylist.dat",
	"user://Users/USERNAME/Songs/Playlists/NormalPlaylists/NormalPlaylists.dat",
	"user://Users/USERNAME/Songs/Streams/SongStreams.dat",
	"user://Users/USERNAME/Songs/Streams/PlaylistStreams.dat",
	"user://Users/USERNAME/Songs/Streams/ArtistStreams.dat",
	"user://Users/USERNAME/Settings/CoreSettings/Settings.dat",
	"user://Users/USERNAME/Settings/CoreSettings/SonqQueue.dat",
	"user://Users/USERNAME/Songs/Playlists/Metadata/PlaylistMetadata.dat",
	"user://Users/USERNAME/Songs/AllSongs/AllSongs.dat",
	"user://Users/USERNAME/Songs/AllSongs/CoverCache.dat",
	"user://Users/USERNAME/Songs/Artists/Names/Artists.dat",
	"user://Users/USERNAME/Songs/Playlists/SmartPlaylists/SmartPlaylists.dat",
	"user://Users/USERNAME/Settings/CoreSettings/TempSmartPlaylist.dat",
	"user://Users/USERNAME/Settings/AudioEffects/AudioEffects.dat",
	"user://Users/USERNAME/Settings/CoreSettings/DownloadQueue.dat",
	"user://Users/USERNAME/Settings/CoreSettings/StdAudioPresets.dat",
]
const global_file_paths : Array = [
	"user://GlobalSettings/UserProfileIdx.dat",
	"user://GlobalSettings/UserNames.dat",
	"user://GlobalSettings/last_loaded_user.dat",
	"user://GlobalSettings/AppStats/UsageTime.dat"
]

# saves the Paths to all the added Folders
var folders : Array =  []
# saves the path of the currently playing Song
# further info has to be fetched from AllSongs
var current_song : String = ""
# saving the Paths of the currently loaded Smart Playlist,
# so the next/prior song can be calculated correctly
var current_temporary_playlist : Dictionary = {}
var pressed_temporary_playlist : Dictionary = {}
var temporary_playlist_conditions : Dictionary = {}
var current_playlist_idx : int = -1
# path : Playlist Index
var song_queue : Dictionary = {} 
var is_song_from_queue : bool = false
# saves the last Song that wasn't played from the Queue the start playing from there
var last_non_queued_song : String = ""
# cover Hash [String] : ImageData [PoolByteArray],
# using this Cache reduced the Texture and Video Memory usage by a factor of 4 -> ~400MB to ~100MB
var cached_covers : Dictionary = {}
# PATH : [TITLE, ARTIST,ALLSONGS_IDX,Streams,COVER_HASH,TAG,DURATION IN SECONDS, LIKED(TRUE/FALSE]
var AllSongs : Dictionary = {}
# playlist_name : {song_path : main_idx}
var normal_playlists : Dictionary = {}
# titles of each Smart Playlist
var smart_playlists : Array = []
# songTitle : Streams
var Streams : Dictionary = {}
# plalistName : Streams
var playlist_streams : Dictionary = {}
# artistName : Streams
var artist_streams : Dictionary = {}
var artists : Array = []
var main_enabled : bool = false
var highlighted_songs : PoolStringArray = []
var audio_effects : Array = [
	# effect in this Array == Effect Idx in AudioBus
	# index 0 in each dictionary saves if the effect is enabled
	{
		"enabled" : false,
		"room_size" : 0.0,
		"damping" : 0.0,
		"spread" : 0.6,
		"hipass" : 0.0,
		"dry" : 0.0,
		"wet" : 1.0,
		"predelay_msec" : 0.0,
		"predelay_feedback" : 0.0,
	},
	{
		"enabled" : false,
		"pan_pullout" : 0.0,
		"time_pullout_ms" : 0.0,
		"surround" : 0.0,
	},
	{
		"enabled" : false,
		"pitch_scale" : 1.0,
	},
	{
		"enabled" : false,
		"cutoff_hz" : 2000.0,
		"resonance" : 0.5,
		"db" : 0.0,
	},
	{
		"enabled" : false,
		"pan" : 0.0
	},
	{
		"enabled" : false,
		"band_db/32_hz" : 0.0,
		"band_db/100_hz" : 0.0,
		"band_db/320_hz" : 0.0,
		"band_db/1000_hz" : 0.0,
		"band_db/3200_hz" : 0.0,
		"band_db/10000_hz" : 0.0
	},
	{
		"enabled" : false,
		"band_db/22_hz" : 0.0,
		"band_db/32_hz" : 0.0,
		"band_db/44_hz" : 0.0,
		"band_db/63_hz" : 0.0,
		"band_db/90_hz" : 0.0,
		"band_db/125_hz" : 0.0,
		"band_db/175_hz" : 0.0,
		"band_db/250_hz" : 0.0,
		"band_db/350_hz" : 0.0,
		"band_db/500_hz" : 0.0,
		"band_db/700_hz" : 0.0,
		"band_db/1000_hz" : 0.0,
		"band_db/1400_hz" : 0.0,
		"band_db/2000_hz" : 0.0,
		"band_db/2800_hz" : 0.0,
		"band_db/4000_hz" : 0.0,
		"band_db/5600_hz" : 0.0,
		"band_db/8000_hz" : 0.0,
		"band_db/11000_hz" : 0.0,
		"band_db/16000_hz"  : 0.0,
		"band_db/22000_hz" : 0.0
	},
	{
		"main_enabled" : false
	}
]

func _enter_tree():
	# apparently should have a better performance on GLES2
	get_tree().get_root().render_direct_to_screen = true
	
	# disabling 3d since it's never used
	get_tree().get_root().set_disable_3d(true)
	get_tree().get_root().usage = Viewport.USAGE_2D
	get_viewport().render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS
	
	get_tree().get_root().set_transparent_background( SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"TransparentBackground") )
	VelesInit.new().create_folders()
	
	var temp = null
	# saving Std Userdata Values to GlobalSettings
	save_user_specific_data(std_userdata_paths)
	
	# global Data
	for i in global_file_paths.size():
		temp = SaveData.load_data(global_file_paths[i])
		if temp != null:
			match i:
				0:
					Global.current_profile_idx = temp
				1:
					Global.user_profiles = temp
				2:
					Global.last_loaded_user = temp
	# user Specific Data
	load_user_specific_data(file_paths)
	var x : VelesInit = VelesInit.new()
	x.create_folders()
	x.init_audio_effects()
	x.init_random_settings()
	x.init_std_covers()


func _exit_tree():
	# retrive Settgins to be Saved
	SettingsData.settings[SettingsData.GENERAL_SETTINGS].is_song_from_queue = is_song_from_queue
	SettingsData.settings[SettingsData.GENERAL_SETTINGS].WindowPosition = OS.get_window_position()
	SettingsData.settings[SettingsData.GENERAL_SETTINGS].WindowSize = OS.get_window_size()
	
	# global Data
	SaveData.save( global_file_paths[0], Global.current_profile_idx)
	SaveData.save( global_file_paths[1], Global.user_profiles)
	SaveData.save( global_file_paths[2], Global.last_loaded_user)
	
	# user Specific Data
	save_user_specific_data( add_users_to_fiie_paths(file_paths) )


func load_user_specific_data(var paths : PoolStringArray) -> void:
	var temp
	for i in paths.size():
		temp = SaveData.load_data( add_user_to_filepath(paths[i]))
		if temp != null:
			match i:
				0:
					folders = temp
				1:
					current_song = temp
				2:
					current_playlist_idx = temp
				3:
					normal_playlists = temp
				4:
					Streams = temp
				5:
					playlist_streams = temp
				6:
					artist_streams = temp
				7:
					SettingsData.settings = temp
				8:
					song_queue = temp
				9:
					# playlist Metadata
					pass
				10:
					# AllSong Paths
					AllSongs = temp
				11:
					cached_covers = temp
					init_cached_covers()
				12:
					artists = temp
				13:
					smart_playlists = temp
				14:
					current_temporary_playlist = temp
				15:
					audio_effects = temp
				16:
					Global.current_downloads = temp
	is_song_from_queue = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"SongFromQueue")


func add_users_to_fiie_paths(var user_paths : PoolStringArray) -> PoolStringArray:
	var formatted_paths : PoolStringArray = []
	for i in user_paths.size():
		formatted_paths.push_back(add_user_to_filepath(user_paths[i]))
	return formatted_paths;


func add_user_to_filepath(var filepath : String) -> String:
	return filepath.format([Global.get_current_user()],"USERNAME")


func save_user_specific_data(var paths : PoolStringArray) -> void:
	# savingg all the data that needs to be saved when laoding this specific user again
	SaveData.save( paths[0] , folders)
	SaveData.save( paths[1] , current_song)
	SaveData.save( paths[2] , current_playlist_idx)
	SaveData.save( paths[3] , normal_playlists)
	SaveData.save( paths[4] , Streams)
	SaveData.save( paths[5] , playlist_streams)
	SaveData.save( paths[6] , artist_streams)
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "PlaybackPosition", MainStream.get_playback_position())
	SaveData.save( paths[7] , SettingsData.settings)
	SaveData.save( paths[8] , song_queue)
	SaveData.save( paths[10] , AllSongs)
	SaveData.save( paths[11] , cached_covers)
	SaveData.save( paths[12] , artists)
	SaveData.save( paths[13] , smart_playlists )
	SaveData.save( paths[14] , current_temporary_playlist )
	SaveData.save( paths[15] , audio_effects )
	SaveData.save( paths[16], Global.current_downloads)


func reset_userdata() -> void:
	load_user_specific_data(std_userdata_paths)


func set_current_song(var path : String) -> void:
	current_song = path


func set_current_playlist(var idx : int) -> void:
	# -2 Smart Playlist
	# -1 = AllSongs
	# 0 -> INF = Index in normal_playlists
	current_playlist_idx = idx


func queue_song(var path : String = "") -> void:
	if song_queue.size() == 0:
		last_non_queued_song = current_song
	if path == "":
		song_queue[current_song] = current_playlist_idx
	else:
		song_queue[path] = Global.pressed_playlist_idx


func clear_queue() -> void:
	song_queue.clear()


func queue_song_finished() -> void:
	if song_queue.erase(song_queue.keys()[0]):
		if song_queue.empty():
			is_song_from_queue = false


func new_playlist(var playlist_name : String) -> void:
	# creates New Key with an Empty Dictionary as Value
	var value : Dictionary = {}
	normal_playlists[playlist_name] = value
	if !SaveData.push_key_and_save(SongLists.add_user_to_filepath(SongLists.file_paths[9]), playlist_name, 0, true, OS.get_datetime()):
		Global.root.message("ERROR://CANNOT EDIT REQUESTED KEY", SaveData.MESSAGE_ERROR)


func new_smart_playlist(var title : String, var conditions : Dictionary) -> void:
	smart_playlists.push_back(title)
	var conditions_filepath : String = Global.get_current_user_data_folder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + title + ".dat"
	SaveData.save(conditions_filepath, conditions)
	if !SaveData.push_key_and_save(SongLists.add_user_to_filepath(SongLists.file_paths[9]),title,0,true,OS.get_datetime()):
		Global.root.message("ERROR://CANNOT EDIT REQUESTED KEY", SaveData.MESSAGE_ERROR)


func append_artists(var idx : int, var new_artists : PoolStringArray) -> void:
	var x : PoolStringArray = artists[idx]
	x.append_array(new_artists)
	artists[idx] = x


func init_cached_covers() -> void:
	# loads already filtered and sorted Covers into a Cache
	# saving loading-time and memory
	# warning-ignore:unused_variable
	var counter = 0
	for x in cached_covers.keys():
		counter += 1
		cached_covers[x] = ImageLoader.get_cover(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + x + ".png", "", Vector2(70,70))


func add_folder(var dir : String):
	folders.push_back(dir)
	var x : SongLoader = SongLoader.new()
	x.Reload()


func remove_folder(var dir : String):
	for n in folders.size():
		if folders[n] == dir:
			folders.remove(n)
			break;


func free_allsongs() -> void:
	self.AllSongs.clear()


func replace_dict_key( var src_dict : Dictionary, var old_key : String, var new_key : String) -> Dictionary:
	# replaces a Dictionaries key while retaining order of the Keys and Values
	var temp_dict : Dictionary = {}
	for i in src_dict.size():
		if src_dict.keys()[i] == old_key:
			temp_dict[ new_key ] = src_dict.values()[i]
		else:
			temp_dict[ src_dict.keys()[i] ] = src_dict.values()[i]
	return temp_dict


func add_highlighted_song(var songspace_vbox : Node, var idx : int) -> void:
	# adds higlighted song to global array when being presse while
	# ctrl-key is held
	var path : String = songspace_vbox.get_child(idx).path
	if !highlighted_songs.has(path):
		highlighted_songs.push_back(songspace_vbox.get_child(idx).path)
	songspace_vbox.get_child(idx).modulate = Color("888888")
