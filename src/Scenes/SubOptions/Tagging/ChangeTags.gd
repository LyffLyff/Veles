extends Control

enum {
	FILENAME,
	ARTIST, 
	TITLE, 
	ALBUM, 
	GENRE, 
	COMMENT, 
	RELEASE_YEAR, 
	TRACK_NUMBER, 
	COVER_DESCRIPTION
}

const song_formats : Array = ["mp3","ogg","flac","wav","opus"]
const dialogue_song_formats : Array = ["*.mp3","*.ogg","*.flac","*.wav","*.opus"]

var line_edits_edited : PoolByteArray = []
var song_paths : PoolStringArray = []
var loaded_covers : Array = []
var current_cover_idx : int = -1

onready var path_edit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Paths/Values/HBoxContainer/LineEdit
onready var path_vbox : VBoxContainer = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Paths/Values
onready var filename_edit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/NameExplorer/SongExplorer
onready var title : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/NameTag/NameTag
onready var artist_edit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Artist/VBoxContainer/HBoxContainer/Artist
onready var artist_vbox : VBoxContainer = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Artist/VBoxContainer
onready var album_edit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Album/Album
onready var genre_edit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/GenreSelection/LineEdit
onready var cover_edit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Cover/Cover/LineEdit
onready var cover_description_edit : TextEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Cover/HBoxContainer/CoverDescription
onready var comment_edit : TextEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Comment/Comment
onready var track_num_edit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/TrackNumber/TrackNumber
onready var release_year_edit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/ReleaseYear/ReleaseYear
onready var cover_hbox : HBoxContainer = $ScrollContainer/VBoxContainer/ScrollContainer/Covers
onready var cover_display : TextureRect = $ScrollContainer/VBoxContainer/ScrollContainer/Covers/Cover
onready var cover_count : Label = $ScrollContainer/VBoxContainer/ScrollContainer/Covers/Cover/Label
onready var rating_box : SpinBox = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Popularity/RatingEdit
onready var tag_edits : Array = [filename_edit, artist_edit, title, album_edit, genre_edit, comment_edit, release_year_edit, track_num_edit, cover_description_edit]

func _ready():
	if get_tree().connect("files_dropped",self,"_on_files_dropped"):
		Global.root.message("CANNOT CONNECT FILES DROPPED SIGNAL TO _on_files_dropped FUNCTION",  SaveData.MESSAGE_ERROR )
	
	# connecting signals
	for n in tag_edits.size():
		line_edits_edited.push_back(false)
		if tag_edits[n] is TextEdit:
			if tag_edits[n].connect("text_changed",self,"on_line_edit_text_entered",["",n]):
				Global.root.message("CANNOT CONNECT TEXT CHANGED SIGNAL TO on_line_edit_text_entered FUNCTION",  SaveData.MESSAGE_ERROR )
		elif tag_edits[n] is LineEdit:
			if tag_edits[n].connect("text_changed",self,"on_line_edit_text_entered",[n]):
				Global.root.message("CANNOT CONNECT TEXT CHANGED SIGNAL TO on_line_edit_text_entered FUNCTION",  SaveData.MESSAGE_ERROR )
	
	# init songpaths
	set_song_paths(Global.temp_tag_paths)
	Global.temp_tag_paths = []


func _on_files_dropped(var files : PoolStringArray,var _screen_idx : int) -> void:
	if Global.general_dialogue_visible:
		return;
	var dis_2_path_edit : float = get_global_mouse_position().distance_to(path_edit.rect_global_position) 
	var dis_2_cover_edit : float = get_global_mouse_position().distance_to(cover_edit.rect_global_position)
	if dis_2_cover_edit < dis_2_path_edit:
		cover_edit.set_text(files[0])
	else:
		set_song_paths(files)

func on_line_edit_text_entered(var _new_text : String,var line_edit_idx : int) -> void:
	line_edits_edited[line_edit_idx] = true


func reset_line_edit_changed() -> void:
	for n in line_edits_edited.size():
		line_edits_edited[n] = false


func free_path_labels() -> void:
	# resetting Everything regarding the Paths,
	# including added Labels of Multiple Paths of Arrays
	song_paths.resize(0)
	for i in range(1, path_vbox.get_child_count()):
		# since I'm removing the child it's always index 1
		var ref = path_vbox.get_child(1)
		path_vbox.remove_child(ref)
		ref.queue_free()


func free_artist_labels() -> void:
	for n in range(1, artist_vbox.get_child_count()):
		# since I'm removing the child it's always index 1
		var ref = artist_vbox.get_child(1)
		artist_vbox.remove_child(ref)
		ref.queue_free()


func set_cover_path(var paths : PoolStringArray) -> void:
	cover_edit.set_text(paths[0])


func rename_song(var old_path : String, var new_path : String, var new_title : String, var path_idx : int) -> bool:
	var dir : Directory = Directory.new()
	if dir.rename(old_path, new_path) == OK:
		
		# current Song
		song_paths[ path_idx ] = new_path
		if old_path == SongLists.current_song:
			SongLists.current_song = new_path
		
		# replacing key in AllSongs
		if SongLists.AllSongs.has(old_path):
			var temp : Array = SongLists.AllSongs.get(old_path)
			temp[0] = new_title
			SongLists.AllSongs.keys()[SongLists.AllSongs.keys().find(old_path,0)] = new_path
			SongLists.AllSongs.values()[SongLists.AllSongs.keys().find(old_path,0)] = temp
			if !SongLists.AllSongs.erase(old_path):
				Global.root.message("PATH THAT YOU WANTED TO ERASE FROM ALLSONGS IS NOT EXISTENT IN IT: " + old_path, SaveData.MESSAGE_ERROR)
		
		# replacing in Playlists
		for n in SongLists.normal_playlists.size():
			if SongLists.normal_playlists.values()[n].has(old_path):
				var value : Array = SongLists.normal_playlists.values()[n].get(old_path)
				if SongLists.normal_playlists.values()[n].erase(old_path):
					value[0] = AllSongs.get_song_amount() -1
					SongLists.normal_playlists.values()[n][new_path] = value
				else:
					Global.root.message("COULD NOT ERASE KEY IN THE PLAYLISTS", SaveData.MESSAGE_ERROR)
		
		# replacing in Streams
		if SongLists.Streams.has(old_path):
			var temp_value = SongLists.Streams.get(old_path)
			if SongLists.Streams.erase(old_path):
				SongLists.Streams[new_path] = temp_value
		
		return true
	else:
		if dir.file_exists(old_path):
			if dir.rename(old_path,new_path) == OK:
				return true;
		return false
 

func init_tags(var valid_paths : PoolStringArray) -> void:
	if valid_paths.size() == 0:
		return
	
	# set covers
	# loading from the file itself
	var cover_data : Array = Tagging.new().get_music_covers(valid_paths[0])
	set_covers(cover_data)
	
	# retrieve Text Tags
	var all_tags : PoolStringArray = []
	all_tags = Tags.get_text_tags(valid_paths[0],[0,1,2,3,4,5,6])
	
	# set Tags
	if all_tags.size() == 0:
		all_tags = ["","","","","","",""]
	
	filename_edit.set_text(valid_paths[0].get_file().get_basename())
	set_artist_line_edits( all_tags[0])
	title.set_text(all_tags[1])
	album_edit.set_text(all_tags[2])
	genre_edit.set_text(all_tags[3])
	comment_edit.set_text(all_tags[4])
	release_year_edit.set_text(all_tags[5])
	track_num_edit.set_text(all_tags[6])
	
	# song Popularity -> [Rating, Counter, Email]
	var song_rating = Tagging.new().get_song_popularity(valid_paths[0])
	if song_rating[0]:
		rating_box.set_value(song_rating[0])
	else:
		rating_box.get_line_edit().set_text("n.a.")


func create_artist_string() -> String:
	var combined_artists : String = ""
	for n in artist_vbox.get_child_count():
		if n == 0:
			combined_artists += artist_vbox.get_child(0).get_child(1).get_text()
		else:
			if artist_vbox.get_child(n).get_child(1).get_text() == "":
				# skips if the Aritst LineEdits has been left empty
				continue;
			combined_artists += artist_vbox.get_child(n).get_child(1).get_text()
		
		if n + 1 < artist_vbox.get_child_count():
			combined_artists += ", "
	return combined_artists


func set_covers(var image_data : Array) -> void:
	# free stuff
	loaded_covers.clear()
	cover_count.text = "1/x"
	 
	# add covers
	var temp_img : Image
	for i in range(len(image_data)):
		#var new_cover : TextureRect = TextureRect.new()
		#new_cover.rect_min_size = Vector2(250, 270)
		#new_cover.expand = true
		#new_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if FormatChecker.identify_image_file(image_data[i].hex_encode()) == 1:
			# the first 23 Bytes of the extracted PNG header cannot be read from godots internal
			# png decoder since they seem to be APIC specific
			# -> needs more testing to see if it works anywhere
			image_data[i] = image_data[i].subarray(23, len(image_data[i]) - 1)
		temp_img = ImageLoader.create_image_from_data(image_data[i])
		#new_cover.set_texture(ImageLoader.image_to_texture(temp_img))
		loaded_covers.push_back(ImageLoader.image_to_texture(temp_img))
		#cover_hbox.add_child(new_cover)
	
	if loaded_covers.size() > 0:
		current_cover_idx = 0
		cover_display.texture = loaded_covers[current_cover_idx]
		cover_count.text = "1/" + str(len(loaded_covers))


func set_artist_line_edits(var Artist_s : String) -> void:
	free_artist_labels()
	var divided_artists : PoolStringArray = Streams.divide_artists(Artist_s)
	for n in divided_artists.size():
		if n == 0:
			artist_edit.set_text(divided_artists[n])
		else:
			_on_AddArtist_pressed()
			artist_vbox.get_child(n).get_node("LineEdit").set_text(divided_artists[n])


func set_song_paths(path_s : PoolStringArray):
	free_path_labels()
	var path_counter : int = 0
	for n in path_s.size():
		if !(path_s[n].get_extension() in song_formats):
			continue
		if path_counter == 0 :
			path_edit.set_text(path_s[n])
		else:
			_on_AddPath_pressed()
			path_vbox.get_child( path_vbox.get_child_count() - 1 ).get_node("LineEdit").set_text(path_s[n])
		path_counter += 1
	song_paths = path_s
	on_song_path_entered(path_s)


func _on_SetTag_pressed():
	# FLAG, DATA, Path
	# only sets the specific tag if the LineEdit hasn't been left empty
	var update_in_songs : bool = false
	var temp_main_idx : int = -1
	var dir : Directory = Directory.new()
	
	# Retrieving Paths of Songs
	song_paths.resize(0)
	var path_candidate : String = ""
	for n in path_vbox.get_children():
		path_candidate = n.get_node("LineEdit").get_text()
		if path_candidate != "":
			song_paths.push_back(path_candidate)
	
	# setting the Changed Tags
	var z : File = File.new()
	for path_idx in song_paths.size():
		if z.open(song_paths[path_idx],File.READ) != OK:
			# skipping the Song if it couldn't be opened
			Global.root.message("File could not be tagged:\n" + song_paths[path_idx], SaveData.MESSAGE_ERROR, true )
			continue;
		
		if FormatChecker.get_music_format_from_data( z.get_buffer(1024).hex_encode() ) == -1 and FormatChecker.get_music_filename_extension(song_paths[ path_idx ]) == -1:
			# if the Real Format is not supported the loop will be skipped
			# -> to prevent false tags
			Global.root.message("FILEFORMAT CANNOT BE TAGGED",  SaveData.MESSAGE_ERROR, true )
			continue;
		z.close()
		
		update_in_songs = false
		if SongLists.AllSongs.has(song_paths[path_idx]):
			# if the Current Song has been added to the AllSongs, certain properties
			# will be changed 
			update_in_songs = true
			temp_main_idx = AllSongs.get_main_idx(song_paths[path_idx])
			
		if dir.file_exists(song_paths[path_idx]):
			Global.root.message("Setting Tags on: " + song_paths[path_idx], SaveData.MESSAGE_NOTICE)
			
			# ARTIST
			if line_edits_edited[ARTIST]:
				var new_artist : String = create_artist_string()
				Tags.set_artist(new_artist, song_paths[ path_idx ])
				if update_in_songs:
					# adding the Changed Artist if not there
					var divided_artists : PoolStringArray = Streams.divide_artists(new_artist)
					for i in divided_artists.size():
						if !SongLists.artists.has([divided_artists[i]]):
							SongLists.artists.push_back([divided_artists[i]])
					
					# setting in AllSongs
					AllSongs.set_song_artist(new_artist,temp_main_idx)
			
			# TITLE
			if line_edits_edited[TITLE]:
				Tags.set_title(title.get_text(),song_paths[ path_idx ])
				if update_in_songs:
					AllSongs.set_song_title(title.get_text(),temp_main_idx)
			
			# ALBUM
			if line_edits_edited[ALBUM]:
				Tags.set_album(album_edit.get_text(),song_paths[ path_idx ])
			
			# GENRE
			Tags.set_genre(genre_edit.get_text(),song_paths[ path_idx ])
			
			# TRACK NUMBER
			if line_edits_edited[TRACK_NUMBER]:
				Tags.set_track_number(track_num_edit.get_text(), song_paths[ path_idx ])
			
			# RELEASE_YEAR
			if line_edits_edited[RELEASE_YEAR]:
				Tags.set_release_year(release_year_edit.get_text(), song_paths[ path_idx ])
			
			# COMMENT
			if line_edits_edited[COMMENT]:
				Tags.set_comment(comment_edit.get_text(), song_paths[ path_idx ])
			
			# COVER_DESCRIPTION
			if line_edits_edited[ COVER_DESCRIPTION ]:
				Tags.set_cover_description(song_paths[ path_idx ], cover_description_edit.get_text())
			
			# Rating
			if rating_box.get_line_edit().text.is_valid_integer():
				Tagging.new().set_song_popularity(song_paths[path_idx], rating_box.get_value(), -1, "")
			
			# File Explorer Name
			if line_edits_edited[0]:
				var new_name : String = filename_edit.get_text()
				var new_folder_path : String = song_paths[ path_idx ].get_base_dir()
				var extension : String = song_paths[ path_idx ].get_extension()
				var new_path : String = new_folder_path +  "/" + new_name + "." + extension
				# needs to reload the Songs since the indexes in the AllSongs Dictionaray would be wrong
				if rename_song(song_paths[ path_idx ],new_path, new_name + "." + extension, path_idx):
					# sets the path string to the new path if renaming was successful
					# to prevent error when trying to set Tags with old nonexistent path
					song_paths[ path_idx ] = new_path
			
			# Cover
			if cover_edit.get_text() != "":
				var cover_path : String = cover_edit.get_text()
				
				# converts a webp image to png to embed in file -> embedded pngs can be shown in OS
				if cover_path.get_extension() == "webp" and SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ConverWebPToPNG"):
					var png_data : PoolByteArray = ImageLoader.webp_to_png(SaveData.load_buffer(cover_path))
					var png_img = ImageLoader.create_image_from_data(png_data)
					if png_img is Image:
						var temp_cover_path : String = "user://temp.png"
						png_img.save_png(temp_cover_path)
						cover_path = SongLists.rel_to_abs_path(temp_cover_path)
				
				Tags.set_cover(
					cover_path,
					song_paths[path_idx],
					ImageLoader.get_image_mime_type(cover_path)
				)
				
				# updating in all songs
				if SongLists.AllSongs.has(song_paths[path_idx]):
					var old_cover_id : String = AllSongs.get_song_coverhash(AllSongs.get_main_idx(song_paths[path_idx]))
					if SongLists.new_cached_covers.has(old_cover_id):
						# erasing if this cover was the only cover of this type perviously
						# only set to [] -> will be filtered by Coverloader
						if SongLists.new_cached_covers.get(old_cover_id)[0].size() <= 1:
							SongLists.new_cached_covers.get(old_cover_id)[0] = []
					var x : CoverLoader = CoverLoader.new()
					x.new_song_covers([song_paths[path_idx]])
		else:
			Global.root.message("Cannot Set Tags on this Fileformat", SaveData.MESSAGE_ERROR, true)
	
	var x : SongLoader = SongLoader.new()
	x.reload()
	reset_line_edit_changed()
	set_song_paths(song_paths)
	init_tags(song_paths)
	Global.root.update_player_infos()


func _on_SelectSong_pressed():
	var dialog = Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"set_song_paths",
		[],
		UsedFilepaths.TAG_PATH,
		dialogue_song_formats,
		false,
		"Select Song"
	)
	$ScrollContainer.set_process_input(false)
	var _err = dialog.connect("exited",$ScrollContainer,"set_process_input", [true])


func _on_SelectCover_pressed():
	var dialog = Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"set_cover_path",
		[],
		UsedFilepaths.TAG_COVER,
		Global.supported_img_extensions,
		false,
		"Select Image"
	)
	$ScrollContainer.set_process_input(false)
	var _err = dialog.connect("exited",$ScrollContainer,"set_process_input", [true])


func _on_AddArtist_pressed():
	var x : HBoxContainer = load("res://src/Scenes/SubOptions/Tagging/AdditionalArtist.tscn").instance()
	if x.get_node("LineEdit").connect("text_changed",self,"on_line_edit_text_entered",[ ARTIST ]):
		Global.root.message("CONNECTING NEW ARTIST LINEEDIT TO on_line_edit_text_entered function", SaveData.MESSAGE_ERROR)
	if x.get_node("LineEdit").connect("tree_exited",self,"on_line_edit_text_entered",["", ARTIST ]):
		Global.root.message("CONNECTING ARTIST LINEEDIT TREE EXITED TO on_line_edit_text_entered function", SaveData.MESSAGE_ERROR)
	artist_vbox.add_child(x)


func on_song_path_entered(var paths : PoolStringArray) -> void:
	var dir : Directory = Directory.new()
	for path in paths:
		if !dir.file_exists(path):
			return;
	init_tags(paths)
	reset_line_edit_changed()


func on_song_path_manually_entered(var path : String) -> void:
	init_tags([path])
	if !Directory.new().file_exists(path):
		return;
	reset_line_edit_changed()


func _on_AddPath_pressed():
	var new_path_edit : HBoxContainer = load("res://src/Scenes/SubOptions/Tagging/AdditionalArtist.tscn").instance()
	new_path_edit.rect_min_size.y = path_edit.rect_min_size.y
	path_vbox.add_child(new_path_edit)


func _on_PriorCover_pressed():
	if current_cover_idx > 0:
		current_cover_idx -= 1
	update_cover()


func _on_NextCover_pressed():
	if current_cover_idx + 1 < len(loaded_covers):
		current_cover_idx += 1
	update_cover()


func update_cover() -> void:
	if loaded_covers.size() == 0:
		return
	cover_count.text = str(current_cover_idx + 1) +  "/" + str(len(loaded_covers))
	cover_display.texture = loaded_covers[current_cover_idx]
