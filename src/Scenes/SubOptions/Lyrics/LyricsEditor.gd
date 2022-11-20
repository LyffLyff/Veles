extends HBoxContainer

const LRF_FILE_EXTENSION : String = ".lrc"
const VPL_FILE_EXTENSION : String = ".vpl"
const TIMESTAMP_CONTAINER : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/LyricsEditor/TimeStampContainer.tscn")
const VERSE_CONTAINER : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/LyricsEditor/VerseContainer.tscn")

var project_path : String = ""
var is_project_up_to_date : bool = true

onready var verse_tools : VBoxContainer = $VBoxContainer/ToolPanel/HBoxContainer/VerseTools
onready var timestamp_tools : VBoxContainer = $VBoxContainer/ToolPanel/HBoxContainer/TimeStampTools
onready var timestamp_vbox : VBoxContainer = $VBoxContainer/ScrollContainer/HBoxContainer/TimeStampVBox
onready var verse_vbox : VBoxContainer = $VBoxContainer/ScrollContainer/HBoxContainer/VerseVBox
onready var project_title_edit : LineEdit = $VBoxContainer/Title
onready var lrc_tags : VBoxContainer = $VBoxContainer/LRCTags
onready var save : TextureButton = $VBoxContainer/PanelContainer/DocOptions/Save
onready var save_as : TextureButton = $VBoxContainer/PanelContainer/DocOptions/SaveAs
onready var embed_in_song : TextureButton = $VBoxContainer/PanelContainer/DocOptions/EmbedInFile

func _ready():
	var _err = timestamp_tools.add_timestamp.connect("pressed", self, "_on_add_timestamp_pressed")
	_err = timestamp_tools.cut_timestamp.connect("pressed", self, "_on_cut_timestamp_pressed")
	_err = verse_tools.add_verse.connect("pressed", self, "_on_add_verse_pressed")
	_err = verse_tools.cut_verse.connect("pressed", self, "_on_cut_verse_pressed")


func _unhandled_key_input(event):
	if event.is_pressed():
		if Input.is_key_pressed(KEY_CONTROL):
			match event.scancode:
				KEY_S:
					# saves the Project, with shift it is "Save As"
					on_save_lyrics_project(Input.is_key_pressed(KEY_SHIFT))
		else:
			if Input.is_key_pressed(KEY_V):
				# all Actions for Verses
				match event.scancode:
					KEY_A:
						_on_add_verse_pressed()
					KEY_D:
						_on_cut_verse_pressed()
			elif Input.is_key_pressed(KEY_T):
				# all Actions for Timestamps
				match event.scancode:
					KEY_A:
						_on_add_timestamp_pressed()
					KEY_D:
						_on_cut_timestamp_pressed()
			elif Input.is_key_pressed(KEY_P):
				_on_add_timestamp_pressed()
				timestamp_vbox.get_child( 
					timestamp_vbox.get_child_count() - 1
				).timestamp_edit.set_text(
					str( 
						MainStream.get_playback_position() 
					).pad_decimals(2)
				)


func n_ready(var prjct_path : String = "") -> void:
	if prjct_path != "":
		match prjct_path.get_extension():
			"lrc":
				create_from_lrc(prjct_path)
			"mp3":
				create_from_song( Tags.get_lyrics(prjct_path) )
			"vlp":
				project_path = prjct_path
				load_project()
	is_project_up_to_date = true
	add_project_to_edited(project_path)


func load_project() -> void:
	var project_data : Array = SaveData.load_data(project_path)
	
	# title
	project_title_edit.set_text(project_data[0])
	
	# LRC Tags
	lrc_tags.artist_edit.set_text(project_data[3][0])
	lrc_tags.album_edit.set_text(project_data[3][1])
	lrc_tags.title.set_text(project_data[3][2])
	lrc_tags.author_edit.set_text(project_data[3][3])
	lrc_tags.song_length_edit.set_text(project_data[3][4])
	lrc_tags.language_menu.set_text(project_data[3][5])
	lrc_tags.file_creator_edit.set_text(project_data[3][6])
	
	# Verses
	init_verses(project_data[1])
	
	# Timestamps
	init_timestamps(project_data[2])


func set_project_path(var new_project_path : String) -> void:
	project_path = new_project_path


func init_verses(var verses : PoolStringArray) -> void:
	for i in verses.size():
		_on_add_verse_pressed()
		verse_vbox.get_child(i).verse_text_edit.set_text(verses[i])
		
		# resizing the Verse TextEdit if the Verse  is Mutliline
		verse_vbox.get_child(i).on_verse_text_changed()


func init_timestamps(var timestamps : PoolRealArray) -> void:
	for i in timestamps.size():
		_on_add_timestamp_pressed()
		timestamp_vbox.get_child(i).timestamp_edit.set_text(str(timestamps[i]))


func create_from_lrc(var lrc_filepath : String) -> void:
	# retreive Encoded Data
	var encoded_project_data : String = SaveData.load_as_text(lrc_filepath)
	var decoded_lrc_file : Array = LRC.new().decode_lrc_file(encoded_project_data)
	
	# info
	project_title_edit.set_text( project_path.get_file().replace(".lrc","") )
	lrc_tags.artist_edit.set_text(decoded_lrc_file[0].values()[0])
	lrc_tags.album_edit.set_text(decoded_lrc_file[0].values()[1])
	lrc_tags.title.set_text(decoded_lrc_file[0].values()[2])
	lrc_tags.author_edit.set_text(decoded_lrc_file[0].values()[3])
	lrc_tags.song_length_edit.set_text(decoded_lrc_file[0].values()[4])
	lrc_tags.language_menu.set_text(decoded_lrc_file[0].values()[5])
	lrc_tags.file_creator_edit.set_text(decoded_lrc_file[0].values()[6])
	
	# verses
	for i in decoded_lrc_file[1].size():
		_on_add_verse_pressed()
		verse_vbox.get_child(i).verse_text_edit.set_text( decoded_lrc_file[1][i] )
		
		# resizing the Verse TextEdit if the Verse  is Mutliline
		verse_vbox.get_child(i).on_verse_text_changed()
	# timeStamps
	for i in decoded_lrc_file[2].size():
		_on_add_timestamp_pressed()
		timestamp_vbox.get_child(i).timestamp_edit.set_text( str( decoded_lrc_file[2][i] ) )


func create_from_api_response(var api_response : Array) -> void:
	# freeing prior Verses/Timestamps
	for verse in verse_vbox.get_children():
		verse.queue_free()
	for timestamp in timestamp_vbox.get_children():
		timestamp.queue_free()
	
	# creating Project from given data
	for i in api_response.size():
		_on_add_verse_pressed()
		_on_add_timestamp_pressed()
		verse_vbox.get_child(i).verse_text_edit.set_text(
			api_response[i]["lyrics"]
		)
		verse_vbox.get_child(i).on_verse_text_changed()
		timestamp_vbox.get_child(i).timestamp_edit.set_text(
			str( api_response[i]["seconds"] )
		)


func create_from_song(var lyrics : Array) -> void:
	match lyrics.size():
		1:
			init_verses(lyrics[0])
		2:
			init_verses(lyrics[0])
			init_timestamps(lyrics[1])


func on_save_lyrics_project(var save_as : bool = false):
	# VLP = Veles Lyrics Project
	# structure = Array
	# [Title, Verses, Timestamps, [Artist, Album, Title, Author, Length, Language, Creator of File] ]
	var title : String = project_title_edit.get_text()
	var VLPFiledata : Array = [
		title,
		get_verses(),
		get_timestamps(),
		[
			lrc_tags.artist_edit.get_text(),
			lrc_tags.album_edit.get_text(),
			lrc_tags.title.get_text(),
			lrc_tags.author_edit.get_text(),
			lrc_tags.song_length_edit.get_text(),
			lrc_tags.language_menu.get_text(),
			lrc_tags.file_creator_edit.get_text()
		]
	]
	
	if Directory.new().file_exists(project_path) and !save_as:
		#The Project already exists, the PreExisting File will
		#be overriden with the new Data
		SaveData.save(project_path.replace("user://", OS.get_user_data_dir() + "/" ), VLPFiledata )
		is_project_up_to_date = true
	else:
		var general_file_dialogue = load("res://src/scenes/General/GeneralFileDialogue.tscn").instance()
		Global.root.top_ui.add_child(general_file_dialogue)
		general_file_dialogue.n_ready(FileDialog.MODE_SAVE_FILE ,FileDialog.ACCESS_USERDATA, "Lyrics",["*.vlp"], true, "Save Project As",title)
		general_file_dialogue.dialogue.current_dir = Global.get_current_user_data_folder() + "/Lyrics/Projects"
		var _err = general_file_dialogue.connect("selection_made", SaveData, "save", [VLPFiledata])
		
		# changing current project path if save as is true
		if save_as:
			_err = general_file_dialogue.connect("selection_made", self, "set_project_path")
		
		_err = general_file_dialogue.connect("selection_made", self, "add_project_to_edited")
		_err = general_file_dialogue.connect("saved", self, "set", ["is_project_up_to_date",true])


func add_project_to_edited(var new_project_path : String) -> void:
	var edited_projects : Array = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "LastEditedVLPProjects")
	if !edited_projects.has(new_project_path):
		edited_projects.push_back(new_project_path)
	else:
		edited_projects.remove(edited_projects.find(new_project_path))
		edited_projects.push_front(new_project_path)
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "LastEditedVLPProjects", edited_projects)


func get_lyrics_project_path(var title : String) -> String:
	return OS.get_user_data_dir() + "/Lyrics/Projects/" + title + VPL_FILE_EXTENSION


func get_verses() -> PoolStringArray:
	var verses : PoolStringArray = []
	for VERSE_CONTAINER in verse_vbox.get_children():
		verses.push_back( VERSE_CONTAINER.verse_text_edit.get_text())
	return verses


func get_timestamps() -> PoolRealArray:
	var timestamps : PoolRealArray = []
	for TIMESTAMP_CONTAINER in timestamp_vbox.get_children():
		timestamps.push_back(float(TIMESTAMP_CONTAINER.timestamp_edit.get_text()))
	return timestamps;


func _on_ExportToLRC_pressed() -> void:
	var title : String = project_title_edit.get_text()
	
	var lrc_file_data : String = LRC.new().encode_lrc_file(
		get_verses(),
		get_timestamps(),
		lrc_tags.artist_edit.get_text(),
		lrc_tags.album_edit.get_text(),
		lrc_tags.title.get_text(),
		lrc_tags.author_edit.get_text(),
		lrc_tags.song_length_edit.get_text(),
		lrc_tags.language_menu.get_text(),
		lrc_tags.file_creator_edit.get_text()
	)
	
	Global.root.load_general_file_dialogue(
		Exporter.new(),
		FileDialog.MODE_SAVE_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"to_LRC",
		[lrc_file_data],
		"ExportLRC",
		["*.lrc"],
		true,
		"Export Project to LRC File"
	)


func _on_add_timestamp_pressed() -> void:
	is_project_up_to_date = false
	var NewTimeStamp = TIMESTAMP_CONTAINER.instance()
	timestamp_vbox.add_child(NewTimeStamp)
	var _err = NewTimeStamp.connect("timestemp_edited",self,"set",["is_project_up_to_date",false])
	
	if verse_vbox.get_child_count() >= timestamp_vbox.get_child_count():
		#a new timestamp will be given the height of the Verse on creation if needed
		NewTimeStamp.rect_min_size.y = verse_vbox.get_child( NewTimeStamp.get_index() ).rect_size.y


func _on_cut_timestamp_pressed(var idx : int = -1):
	is_project_up_to_date = false
	if idx == -1:
		#if the given index is invalid the lowest timestamp will be deleted
		if timestamp_vbox.get_child_count() == 0:
			return
		idx = timestamp_vbox.get_child_count() - 1
	timestamp_vbox.get_child(idx).queue_free()


func _on_add_verse_pressed() -> void:
	is_project_up_to_date = false
	var new_verse = VERSE_CONTAINER.instance()
	var _err = new_verse.connect("verse_rect_changed",self,"_on_verse_rect_changed")
	_err = new_verse.connect("verse_text_edited",self,"set",["is_project_up_to_date",false])
	verse_vbox.add_child( new_verse )


func _on_cut_verse_pressed(var idx = -1) -> void:
	is_project_up_to_date = false
	if idx == -1:
		if verse_vbox.get_child_count() == 0:
			return
		idx = verse_vbox.get_child_count() - 1
	verse_vbox.get_child(idx).queue_free()


func _on_verse_rect_changed(var verse_idx : int, var new_height : int) -> void:
	if verse_idx < timestamp_vbox.get_child_count():
		timestamp_vbox.get_child(verse_idx).rect_min_size.y = new_height


func _on_Return_pressed():
	if !is_project_up_to_date:
		#Asking if they want to leave without saving
		var x : Node = load("res://src/Scenes/General/QuestionDialog.tscn").instance()
		Global.root.add_child(x)
		x.n_ready( "Leave Project without Saving?" )
		var _err = x.connect("agreed",Global.root,"load_option",[6,true])
	else:
		#If Porject is up to Date it won't display Notice
		Global.root.load_option(6,true)


func _on_Title_text_entered(var _new_title : String):
	is_project_up_to_date = false


func _on_DeleteProjectFile_pressed():
	# deleting the Current Project and returning to the Project Selection screen
	if Directory.new().remove(project_path) != OK:
		Global.root.message("REMOVING PROJECT FILE: " + project_path,  SaveData.MESSAGE_ERROR )
	_on_Return_pressed()


func _on_EmbedInFile_pressed():
	var verses : PoolStringArray = get_verses()
	var timestamps : PoolRealArray = get_timestamps()
	var is_synchronized : bool = verses.size() == timestamps.size()
	
	Global.root.load_general_file_dialogue(
		Tags,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"set_lyrics",
		[is_synchronized, verses, timestamps],
		"",
		["*.mp3","*.ogg","*.wav"],
		false,
		"Embed In Song"
	)


func _on_OpenInFileManager_pressed():
	var npath : String = project_path.replace(project_path.get_file(),"").replace("user://",OS.get_user_data_dir() + "/")
	if OS.shell_open( 	npath ) != OK:
		Global.root.message("OPENING PROJECT DIRECTORY: " + npath,  SaveData.MESSAGE_ERROR )


func _on_SaveAs_pressed() -> void:
	on_save_lyrics_project(true)


func _on_API_pressed():
	var api_fetch : Node = load("res://src/Scenes/SubOptions/Lyrics/APIFetch.tscn").instance()
	var _err = api_fetch.connect("overwrite_project",self,"create_from_api_response")
	get_parent().add_child(api_fetch)


func _on_PasteFromClipboard_pressed():
	# pastes a text from the clipboard and puts each line (divided by newline) in a new verse
	var clipboard_text : PoolStringArray = OS.get_clipboard().split("\n")
	for i in clipboard_text.size():
		_on_add_verse_pressed()
		verse_vbox.get_child( verse_vbox.get_child_count() - 1 ).verse_text_edit.text = clipboard_text[i]
