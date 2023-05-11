extends VBoxContainer

signal cover_set
signal covers_initialised
signal save_tags

const TAG_COVER_MENU : PackedScene = preload("res://src/Scenes/SubOptions/Tagging/TagCoverMenu.tscn")
const STD_MENU_OPTIONS : Array = ["<retain>","<empty>"]

onready var cover_switcher : MarginContainer = $Tags/MarginContainer/VboxContainer/HBoxContainer/CoverSwitcher
onready var image_properties : VBoxContainer = $Tags/MarginContainer/VboxContainer/HBoxContainer/ImageProperties
onready var title_menu : Control = $Tags/MarginContainer/VboxContainer/TextTags/TitleMenu
onready var artist_menu : Control = $Tags/MarginContainer/VboxContainer/TextTags/ArtistMenu
onready var album_menu : Control = $Tags/MarginContainer/VboxContainer/TextTags/AlbumMenu
onready var genre_menu : Control = $Tags/MarginContainer/VboxContainer/TextTags/GenreMenu
onready var track_menu : Control = $Tags/MarginContainer/VboxContainer/TextTags/Numbers/TrackMenu
onready var year_menu : Control = $Tags/MarginContainer/VboxContainer/TextTags/Numbers/YearMenu
onready var rating_edit : SpinBox = $Tags/MarginContainer/VboxContainer/TextTags/RatingEdit
onready var comment_edit : TextEdit = $Tags/MarginContainer/VboxContainer/TextTags/CommentEdit
onready var status_indicator : Label = $Status


var current_filepaths : PoolStringArray = []
var current_item_idx : int = -1
var cover_thread : ThreadWrapper = null
var _err : int
var temporary_tags : Dictionary = {
	Enumerations.ARTIST : PoolStringArray(),
	Enumerations.ALBUM : PoolStringArray(),
	Enumerations.TITLE : PoolStringArray(),
	Enumerations.GENRE : PoolStringArray(),
	Enumerations.TRACK_NUMBER : PoolStringArray(),
	Enumerations.RELEASE_YEAR : PoolStringArray(),
	Enumerations.COMMENT : PoolStringArray(),
}

func _ready():
	_err = cover_switcher.connect("right_clicked", self, "init_tag_cover_menu")
	_err = cover_switcher.connect("left_clicked", self, "init_tag_cover_menu")
	_err = cover_switcher.connect("cover_updated", self, "update_image_properties")
	_err = Global.connect("covers_edited", self, "reload")
	_err = Global.connect("covers_edited", self, "on_covers_edited", [], CONNECT_DEFERRED)
	
	# init lineedit menus
	title_menu.add_static_options(STD_MENU_OPTIONS)
	title_menu.connect("menu_to_be_shown", get_owner(), "on_single_menu_about_to_be_shown", [title_menu, Enumerations.TITLE])
	
	artist_menu.add_static_options(STD_MENU_OPTIONS)
	artist_menu.connect("menu_to_be_shown", get_owner(), "on_single_menu_about_to_be_shown", [artist_menu, Enumerations.ARTIST])
	
	track_menu.add_static_options(STD_MENU_OPTIONS)
	track_menu.connect("menu_to_be_shown", get_owner(), "on_single_menu_about_to_be_shown", [track_menu, Enumerations.TRACK_NUMBER])
	
	album_menu.add_static_options(STD_MENU_OPTIONS)
	album_menu.connect("menu_to_be_shown", get_owner(), "on_single_menu_about_to_be_shown", [album_menu, Enumerations.ALBUM])
	
	year_menu.add_static_options(STD_MENU_OPTIONS)
	year_menu.connect("menu_to_be_shown", get_owner(), "on_single_menu_about_to_be_shown", [year_menu, Enumerations.RELEASE_YEAR])
	
	genre_menu.add_static_options(STD_MENU_OPTIONS + load("res://src/Scenes/SubOptions/Tagging/GenreList.gd").music_genres)
	
	# init status changes
	title_menu.line_edit.connect("text_changed", self, "update_status_indicator", [status_indicator.STATUSES.SINGLE_FILE_UNSAVED])
	track_menu.line_edit.connect("text_changed", self, "update_status_indicator", [status_indicator.STATUSES.SINGLE_FILE_UNSAVED])
	album_menu.line_edit.connect("text_changed", self, "update_status_indicator", [status_indicator.STATUSES.SINGLE_FILE_UNSAVED])
	year_menu.line_edit.connect("text_changed", self, "update_status_indicator", [status_indicator.STATUSES.SINGLE_FILE_UNSAVED])
	genre_menu.line_edit.connect("text_changed", self, "update_status_indicator", [status_indicator.STATUSES.SINGLE_FILE_UNSAVED])


func set_sidebar_tags(var filepaths : PoolStringArray, var new_item_idx : int, var thread : bool = true) -> void:
	# init temporary tags
	var text_tags : PoolStringArray = Tags.get_text_tags(filepaths[0], [0,1,2,3,4,5,6])
	for i in text_tags.size():
		if text_tags[i] != "":
			if i == Enumerations.ARTIST:
				temporary_tags[i] = Artist.divide_artists(text_tags[i])
			else:
				temporary_tags[i] = [text_tags[i]]
		else:
			temporary_tags[i] = []
	
	current_item_idx = new_item_idx
	
	current_filepaths = filepaths
	
	
	if current_filepaths.size() > 1:
		set_to_retain()
		return
	
	# set text teags
	text_tags.append(Tags.get_song_rating(filepaths[0]))
	set_menu_line_edits(text_tags)
	artist_menu.line_edit_list.set_items(Artist.divide_artists(text_tags[Enumerations.ARTIST]))
	title_menu.line_edit.text = text_tags[Enumerations.TITLE]
	album_menu.line_edit.text = text_tags[Enumerations.ALBUM]
	genre_menu.line_edit.text = text_tags[Enumerations.GENRE]
	comment_edit.text = text_tags[Enumerations.COMMENT]
	year_menu.line_edit.text = text_tags[Enumerations.RELEASE_YEAR]
	track_menu.line_edit.text = text_tags[Enumerations.TRACK_NUMBER]
	rating_edit.value = int(Tags.get_song_rating(filepaths[0]))
	
	# set cover
	cover_thread = ThreadWrapper.new()
	self.add_child(cover_thread)
	if thread and cover_thread.start_thread(self, "init_covers", filepaths[0]) == OK:
		if !self.is_connected("covers_initialised", cover_thread, "end_thread"):
			_err = self.connect("covers_initialised", cover_thread, "end_thread", [], CONNECT_ONESHOT)
		if !self.is_connected("covers_initialised", self, "update_cover"):
			_err = self.connect("covers_initialised", self, "update_cover", [])
	else:
		init_covers(filepaths[0])
		update_cover()
		cover_thread.end_thread()


func reload() -> void:
	# reload the currently loaded tags with the same filepath
	set_sidebar_tags(current_filepaths, current_item_idx, false)


func clear_tags() -> void:
	set_sidebar_tags([""], -1)


func init_covers(var filepath : String) -> void:
	cover_switcher.set_covers(ImageLoader.new().get_embedded_covers(filepath)[0])
	update_image_properties(0)
	self.call_deferred("emit_signal", "covers_initialised")


func on_covers_edited() -> void:
	if SongLists.AllSongs.has(current_filepaths[0]):
		var old_cover_id : String = AllSongs.get_song_coverhash(AllSongs.get_main_idx(current_filepaths[0]))
		if SongLists.new_cached_covers.has(old_cover_id):
			 # erasing if this cover was the only cover of this type perviously
			 # only set to [] -> will be filtered by Coverloader
			if SongLists.new_cached_covers.get(old_cover_id)[0].size() <= 1:
				SongLists.new_cached_covers.get(old_cover_id)[0] = []
			var x : CoverLoader = CoverLoader.new()
			x.new_song_covers([current_filepaths[0]])


func update_cover() -> void:
	if current_filepaths[0] == SongLists.current_song:
		Global.root.player.current_covers = cover_switcher.current_covers
		Global.root.update_player_infos(false, false)
	
	self.call_deferred("emit_signal", "cover_set")


func get_sidebar_values() -> PoolStringArray:
	# returns all values of the line-/textedits from the currently loaded sidebar files
	# (Only returns the Text Tags)
	var values : PoolStringArray = []
	
	values.push_back(current_filepaths[0].get_file())
	values.push_back(Artist.combine_artists(artist_menu.get_line_edit_values()))
	values.push_back(title_menu.line_edit.text)
	values.push_back(album_menu.line_edit.text)
	values.push_back(genre_menu.line_edit.text)
	values.push_back(comment_edit.text)
	values.push_back(year_menu.line_edit.text)
	values.push_back(track_menu.line_edit.text)
	
	return values


func _on_SaveTags_pressed():
	self.emit_signal("save_tags")


func init_tag_cover_menu() -> void:
	if current_filepaths[0] == "":
		return
	var tag_cover_menu : Control = TAG_COVER_MENU.instance()
	Global.root.top_ui.add_child(tag_cover_menu)
	tag_cover_menu.init_options(current_filepaths[0], cover_switcher.cover_idx)


func set_menu_line_edits(var values : PoolStringArray) -> void:
	artist_menu.line_edit_list.set_items(Artist.divide_artists(values[Enumerations.ARTIST]))
	title_menu.line_edit.text = values[Enumerations.TITLE]
	album_menu.line_edit.text = values[Enumerations.ALBUM]
	genre_menu.line_edit.text = values[Enumerations.GENRE]
	comment_edit.text = values[Enumerations.COMMENT]
	year_menu.line_edit.text = values[Enumerations.RELEASE_YEAR]
	track_menu.line_edit.text = values[Enumerations.TRACK_NUMBER]
	rating_edit.line_edit.text = values[Enumerations.RATING]


func external_tag_edit(var edited_tag : String, var item_idx : int, var idx : int) -> void:
	# set the tag edit (unsaved) to the new tag
	if item_idx != current_item_idx:
		return
	
	var idx_offset : int = 1	# filename offsets the actual idx 
	match idx - idx_offset:
		Enumerations.ARTIST:
			artist_menu.set_multi_line_values(Artist.divide_artists(edited_tag))
		Enumerations.TITLE:
			title_menu.line_edit.text = edited_tag
		Enumerations.ALBUM:
			album_menu.line_edit.text = edited_tag
		Enumerations.COMMENT:
			comment_edit.text = edited_tag
		Enumerations.GENRE:
			genre_menu.line_edit.text = edited_tag
		Enumerations.TRACK_NUMBER:
			track_menu.line_edit.text = edited_tag
		Enumerations.RELEASE_YEAR:
			year_menu.line_edit.text = edited_tag
		_:
			# filename and other tags not in the sidebar
			pass
	
	update_status_indicator("", status_indicator.STATUSES.SINGLE_FILE_UNSAVED)


func add_path(var new_path : String) -> void:
	current_filepaths.push_back(new_path)


func set_to_retain() -> void:
	# sets the tag sidebar values to a <retain> tag when multiple files are selected
	var retain_values : PoolStringArray = ["<retain>", "<retain>", "<retain>", "<retain>", "<retain>", "<retain>", "<retain>", "<retain>"]
	set_menu_line_edits(retain_values)
	
	# set the cover to standard
	cover_switcher.cover.texture = load("res://src/Assets/Icons/White/Tagging/cd_72px.png")
	image_properties.multiple_selected()


func update_image_properties(var cover_idx : int) -> void:
	if cover_switcher.current_covers.size() > cover_idx:
		var properties : Dictionary = Tagging.new().get_image_properties(current_filepaths[0], cover_idx)
		if cover_switcher.current_covers[cover_idx].get_data():
			properties["dimensions"] = cover_switcher.current_covers[cover_idx].get_data().get_size()
		else:
			properties["dimensions"] = Vector2.ZERO
		image_properties.init_image_properties(properties["dimensions"], properties["size"], properties["mime_type"], properties["image_type"])


func update_status_indicator(var _text, var new_status : int) -> void:
	status_indicator.set_status(new_status)


func _on_RatingEdit_value_changed(_value):
	update_status_indicator("", status_indicator.STATUSES.SINGLE_FILE_UNSAVED)
