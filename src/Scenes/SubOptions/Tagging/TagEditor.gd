extends Control

const song_formats : Array = ["mp3","ogg","flac","wav","opus"]
const dialogue_song_formats : Array = ["*.mp3","*.ogg","*.flac","*.wav","*.opus"]

onready var divided_container : Control  = $VBoxContainer/HBoxContainer/DividedContainer
onready var item_tags_sidebar : VBoxContainer = $VBoxContainer/HBoxContainer/ItemTagsSidebar
onready var tagging_options : Control = $VBoxContainer/HBoxContainer/TaggingOptions

var err : int 
var loaded_files : PoolStringArray = []
var current_directory : String = ""
var thread : Thread = Thread.new()


func _ready():
	Global.root.init_context_menus()
	
	# connect options
	err = tagging_options.connect("directory_selected", self, "open_directory")
	err = tagging_options.connect("files_selected", self, "open_files")
	err = tagging_options.connect("refresh_directory", self, "open_directory")
	err = tagging_options.connect("remove_tag", self, "remove_tag")
	err = tagging_options.connect("to_parent_directory", self, "open_parent_directory")
	err = item_tags_sidebar.connect("save_tags", self, "save_tags")
	err = divided_container.connect("item_selected", self, "set_single_path")
	err = divided_container.connect("additional_item_selected", self, "append_path")
	
	err = Global.connect("covers_edited", self, "on_covers_edited")
	
	# init divided container
	self.init_headers()
	err = divided_container.connect("item_selected", self, "on_item_selected")
	err = divided_container.connect("item_edited", self, "on_item_edited")
	err = divided_container.connect("item_options_selected", self, "on_item_options_selected")
	err = divided_container.connect("additional_item_selected", self, "additional_item_highlighted")
	
	# fill content
	if Global.temp_tag_paths.size() != 0:
		open_files(Global.temp_tag_paths)
		Global.temp_tag_paths = []
	else:
		# loading last opened files / directory
		var last_opened_folder = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "LastTagFolder")
		if last_opened_folder and last_opened_folder[0] != "":
			open_directory(last_opened_folder[0])
		else:
			open_files(SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "LastTagFiles"))


func _exit_tree():
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "LastTagFolder", [current_directory, false])
	if current_directory == "":
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "LastTagFiles", loaded_files)


func _unhandled_key_input(event):
	# control shortcuts -> CTRL + S,......
	if event.is_pressed() and Input.is_key_pressed(KEY_CONTROL):
		match event.scancode:
			KEY_S:
				save_tags()


func init_headers() -> void:
	var headers : PoolStringArray = ["Filename:", "Artist:", "Title:", "Album:", "Genre:", "Comment:", "Release Year:", "Track Number:"]
	var call_backs : PoolStringArray = ["external_tag_edit", "external_tag_edit", "external_tag_edit", "external_tag_edit", "external_tag_edit", "external_tag_edit", "external_tag_edit", "external_tag_edit"]
	divided_container.clear_sections()
	divided_container.callback_object = item_tags_sidebar
	for i in range(len(headers)):
		divided_container.append_section(true, call_backs[i])
		divided_container.set_header(i, headers[i])


func open_directory(var directory_path : String = current_directory) -> void:
	if !Directory.new().dir_exists(directory_path) or directory_path == "":
		return
	
	current_directory = directory_path
	open_files(ExtendedDirectory.get_files_in_directory(directory_path, Global.audio_extensions))
	
	Global.message("Successfully Loaded Directory", Enumerations.MESSAGE_SUCCESS, true)


func open_files(var filepaths : PoolStringArray) -> void:
	current_directory = ""
	divided_container.clear_items()
	
	if filepaths.size() == 0:
		item_tags_sidebar.clear_tags()
		return
	
	loaded_files = filepaths
	
	var text_tags : Array = Tags.get_multiple_text_tags(filepaths, [0,1,2,3,4,5,6])
	var temp_item_values : Array = []
	for i in filepaths.size():
		temp_item_values.append(filepaths[i].get_file())
		temp_item_values.append_array(text_tags[i])
		divided_container.append_item(temp_item_values)
		temp_item_values = []
	
	item_tags_sidebar.set_sidebar_tags(filepaths, true)


func open_parent_directory() -> void:
	if current_directory == "":
		Global.message("NO DIRECTORY OPEN", Enumerations.MESSAGE_NOTICE, true)
		return
	
	open_directory(ExtendedDirectory.get_parent_directory(current_directory))


func on_item_selected(var item_idx : int) -> void:
	# when a item get left clicked -> prior selections will be freed
	item_tags_sidebar.set_sidebar_tags([loaded_files[item_idx]], true)


func on_item_edited(var item_idx, var section_idx, var new_value : String) -> void:
	if section_idx == 0:
		var new_folder_path : String = loaded_files[item_idx].get_base_dir()
		var new_path : String = new_folder_path +  "/" + new_value
		# needs to reload the Songs since the indexes in the AllSongs Dictionaray would be wrong
		if rename_song(loaded_files[item_idx], new_path, new_value, item_idx):
			# sets the path string to the new path if renaming was successful
			# to prevent error when trying to set Tags with old nonexistent path
			loaded_files[item_idx] = new_path
		else:
			# reloading the item so old file will be set again
			reload_items([item_idx + 1])


func additional_item_highlighted(var item_idx : int) -> void:
	var path : String = get_path_from_idx(item_idx)
	item_tags_sidebar.current_filepaths.push_back(path)
	var text_tags : PoolStringArray = Tags.get_text_tags(path, [0,1,2,3,4,5,6])
	
	for i in text_tags.size(): 
		if text_tags[i] != "" and !item_tags_sidebar.temporary_tags[i].has(text_tags[i]):
			if i == Enumerations.ARTIST:
				var div_artists : PoolStringArray = []
				for j in div_artists.size():
					if !item_tags_sidebar.temporary_tags[i].has(div_artists[j]):
						item_tags_sidebar.temporary_tags[i].push_back(div_artists[j])
			else:
				item_tags_sidebar.temporary_tags[i].push_back(text_tags[i])


func on_item_options_selected(var item_idx : int) -> void:
	var item_options : Control = load("res://src/Scenes/SubOptions/Tagging/TagItemOptions.tscn").instance()
	Global.root.top_ui.add_child(item_options)
	item_options.init_item_options(loaded_files[item_idx])
	item_options.connect("extended_tags_pressed", self, "load_extended_tag_menu", [item_idx])


func get_path_from_idx(var item_idx : int) -> String:
	var path : String = ""
	if current_directory != "":
		path =  current_directory + "/" + divided_container.get_item_values(item_idx)[0]
	else:
		path = loaded_files[item_idx]
	return path


func save_tags():
	item_tags_sidebar.update_status_indicator("", item_tags_sidebar.status_indicator.STATUSES.SINGLE_FILE_SAVED)
	if item_tags_sidebar.current_filepaths.size() == 0:
		return
	
	var filepath : String = ""
	
	for i in item_tags_sidebar.current_filepaths.size():
		filepath = item_tags_sidebar.current_filepaths[i]
		
		# check if file exists
		if !Directory.new().file_exists(filepath):
			Global.message("File does not exist", Enumerations.MESSAGE_ERROR, true)
			return
		
		var combined_artist : String = Artist.combine_artists(item_tags_sidebar.artist_menu.get_line_edit_values())
		
		# check if current file is loaded within Veles -> needs to be updated
		if SongLists.AllSongs.has(filepath):
			var main_idx : int = AllSongs.get_main_idx(filepath)
			AllSongs.set_song_title(item_tags_sidebar.title_menu.line_edit.text, main_idx)
			AllSongs.set_song_artist(combined_artist, main_idx)
		
		# TITLE
		set_text_tag(filepath, Enumerations.TITLE, item_tags_sidebar.title_menu.line_edit.get_text())
		
		# ARTIST
		Tags.set_artist(combined_artist, filepath)
		
		# ALBUM
		set_text_tag(filepath, Enumerations.ALBUM, item_tags_sidebar.album_menu.line_edit.get_text())
		
		# GENRE
		set_text_tag(filepath, Enumerations.GENRE, item_tags_sidebar.genre_menu.line_edit.get_text())
		
		# TRACK NUMBER
		set_text_tag(filepath, Enumerations.TRACK_NUMBER, item_tags_sidebar.track_menu.line_edit.get_text())
		
		# RELEASE_YEAR
		set_text_tag(filepath, Enumerations.RELEASE_YEAR, item_tags_sidebar.year_menu.line_edit.get_text())
		
		# COMMENT
		Tags.set_comment(item_tags_sidebar.comment_edit.get_text(), filepath)
		
		# Song Rating
		if item_tags_sidebar.rating_edit.get_line_edit().text.is_valid_integer():
			Tags.set_rating(item_tags_sidebar.rating_edit.value, filepath)
		elif item_tags_sidebar.rating_edit.get_line_edit().text != "<retain>":
			Global.message("Entered Rating was invalid", Enumerations.MESSAGE_ERROR, true)
		
		# Reload Player Infos
		if filepath == SongLists.current_song:
			Global.root.update_player_infos(true, true, "", filepath)
		
	# Reload Tags in Sidebar
	item_tags_sidebar.reload()
		
	# Reload Item/s
	reload_items(divided_container.highlighted_items)
		
	# Save Userdata
	SongLists.save_user_specific_data(SongLists.add_users_to_filepaths(SongLists.file_paths))


func set_text_tag(var filepath : String, var tag_index : int, var line_edit_text : String) -> void:
	var new_tag_value : String = ""
	match line_edit_text:
		"<retain>":
			# keep value that was previously in
			return
		"<empty>":
			# set the value empty
			new_tag_value = ""
		_:
			# -> normal case, set to line_edits text
			new_tag_value = line_edit_text
	
	match tag_index:
		Enumerations.TITLE:
			Tags.set_title(new_tag_value, filepath)
		Enumerations.ARTIST:
			Tags.set_artist(new_tag_value, filepath)
		Enumerations.ALBUM:
			Tags.set_album(new_tag_value, filepath)
		Enumerations.GENRE:
			Tags.set_genre(new_tag_value, filepath)
		Enumerations.TRACK_NUMBER:
			Tags.set_track_number(new_tag_value, filepath)
		Enumerations.RELEASE_YEAR:
			Tags.set_release_year(new_tag_value, filepath)


func remove_tag() -> void:
	Tags.remove_tag(item_tags_sidebar.current_filepaths[0])
	item_tags_sidebar.reload()
	reload_current_item()


func reload_items(var item_idxs : PoolIntArray) -> void:
	# reloads the given items at the index with updated values
	var temp_path : String = ""
	var values : PoolStringArray = []
	for i in item_idxs.size():
		temp_path = loaded_files[item_idxs[i] - 1]
		values = [temp_path.get_file()]
		values.append_array(Tags.get_text_tags(temp_path, [0, 1, 2, 3, 4, 5, 6]))
		divided_container.set_item_values(item_idxs[i], values)


func reload_current_item() -> void:
	divided_container.set_item_values(divided_container.focused_item_idx, item_tags_sidebar.get_sidebar_values())


func on_single_menu_about_to_be_shown(var ref : Control, var tag_index : int) -> void:
	ref.add_temporary_options(item_tags_sidebar.temporary_tags.get(tag_index))


func set_single_path(var item_idx : int) -> void:
	item_tags_sidebar.current_filepaths = [get_path_from_idx(item_idx)]


func append_path(var item_idx : int) -> void:
	item_tags_sidebar.add_path(get_path_from_idx(item_idx))
	item_tags_sidebar.set_to_retain()


func load_extended_tag_menu(var filepath : String, var item_idx : int) -> void:
	var extended_tag_editor : Control = load("res://src/Scenes/SubOptions/Tagging/ExtendedTagEditor.tscn").instance()
	Global.root.top_ui.add_child(extended_tag_editor)
	extended_tag_editor.init_extended_tag_editor(filepath)
	divided_container.toggle_container(false)
	extended_tag_editor.connect("tree_exited", divided_container, "toggle_container", [true])
	extended_tag_editor.connect("tree_exited", self, "reload_items", [[item_idx +  1]])


func rename_song(var old_path : String, var new_path : String, var new_title : String, var item_idx : int) -> bool:
	if !new_title.is_valid_filename():
		Global.message("Invalid Filename!!", Enumerations.MESSAGE_ERROR, true)
		return false
	
	var dir : Directory = Directory.new()
	if dir.rename(old_path, new_path) == OK:
		
		# replace in variables
		var idx : int = item_tags_sidebar.current_filepaths.find(old_path)
		if idx != -1:
			item_tags_sidebar.current_filepaths[idx] = new_path
		
		# replace if current song
		if old_path == SongLists.current_song:
			SongLists.current_song = new_path
		
		# replacing key in AllSongs
		if SongLists.AllSongs.has(old_path):
			var temp : Array = SongLists.AllSongs.get(old_path, [])
			temp[0] = new_title
			SongLists.AllSongs[new_path] = temp
			if !SongLists.AllSongs.erase(old_path):
				Global.message("PATH THAT YOU WANTED TO ERASE FROM ALLSONGS IS NOT EXISTENT IN IT: " + old_path, Enumerations.MESSAGE_ERROR)
		
		# replacing in Playlists
		for n in SongLists.normal_playlists.size():
			if SongLists.normal_playlists.values()[n].has(old_path):
				var value : Array = SongLists.normal_playlists.values()[n].get(old_path)
				if SongLists.normal_playlists.values()[n].erase(old_path):
					value[0] = AllSongs.get_song_amount() -1
					SongLists.normal_playlists.values()[n][new_path] = value
				else:
					Global.message("COULD NOT ERASE KEY IN THE PLAYLISTS", Enumerations.MESSAGE_ERROR)
		
		# replacing in Streams
		if SongLists.Streams.has(old_path):
			var temp_value = SongLists.Streams.get(old_path)
			if SongLists.Streams.erase(old_path):
				SongLists.Streams[new_path] = temp_value
		
		#Global.init_songs = true
		Global.root.update_player_infos(false, false, old_path, new_path)
		return true
	else:
		return false


func on_covers_edited() -> void:
	var added_paths = []
	for filepath in item_tags_sidebar.current_filepaths:
		if AllSongs.get_main_idx(filepath) != -1:
			added_paths.push_back(filepath)
	CoverLoader.new().new_song_covers(added_paths)
	if SongLists.current_song in added_paths:
		Global.root.update_player_infos(true, true, "", SongLists.current_song)
