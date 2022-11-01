extends Control


#CONSTANTS
const SONG_OPTIONS_OFFSET : int = 40
const MIN_HEADER_SIZE : int = 55
const MAX_HEADER_SIZE : int = 154
const HEADER_LABEL_HEIGHT : int = 16

#NODES
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var songs : VBoxContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
onready var SongScroller : ScrollContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
onready var SongHighlighter : HBoxContainer = null
onready var title : Label = null
onready var PlaylistOptions : TextureButton
onready var HeaderCover : TextureRect = null
onready var Infos : Array = []

#VARIABLES
var HighLightedSong : Resource = preload("res://src/Ressources/Themes/Song/HighlightedSong.tres")
var GeneralDialogue : PackedScene = preload("res://src/scenes/General/GeneralFileDialogue.tscn")
#saves the Rect of the Song Scroller -> will be updated using the resized signal
var SongScrollerRect : Rect2
var Idx : int = -1
var TempPos : float = -1.0
var TempIdx : int = -1
var SongOptionsRef : Node = null
var PlaylistIdx : int = -1
var ScrollingFast : bool = false
var LastMousePos : Vector2 = Vector2()
var HeaderExpanded : bool = true
var LastScrollValue : float = 0.0
var CurrScrollValue : float = 0.0


func _ready():
	_on_SongScroller_resized()


func _exit_tree():
	FreeHighlightedSongs()


func _process(_delta):
	TempIdx =  SongScroller.RealIndex(SongScroller.calc_idx())
	if !ScrollingFast:
		if SongScrollerRect.has_point(get_global_mouse_position()) and (Idx != TempIdx or TempPos != songs.rect_position.y):
			Idx = TempIdx
			if Idx >= 0:
				#SongHighlighter.show()
				TempPos = songs.rect_position.y
				SongHighlighter.rect_global_position.y = songs.get_child(TempIdx).rect_position.y + SongScroller.rect_global_position.y + TempPos
			else:
				pass
				#Fixing the Issue of the Highlighter being visible when no songs are in a playlist
				#Only will be set on Idx Change
				#SongHighlighter.hide()
	else:
		if TempIdx >= 0:
			if SongScrollerRect.has_point(get_global_mouse_position()):
				SongHighlighter.rect_global_position.y = get_global_mouse_position().y


func ConnectScrollContainer() -> void:
	if songs.get_parent().connect("space_pressed",self,"OnLeftMouseButtonClicked"):
		Global.root.Message("CONNECTING SPACE PRESSED SIGNAL WITH LEFT BUTTON CLICKED FUNCTION",  SaveData.MESSAGE_ERROR )
	if songs.get_parent().connect("space_rightclick",self,"OnSongSpaceOptions"):
		Global.root.Message("CONNECTING SPACE RIGHTCLICKED SIGNAL WITH RIGHT BUTTON CLICKED FUNCTION",  SaveData.MESSAGE_ERROR )


func UnloadPlaylist():
	root.DeleteCurrentoption()
	root.options.add_child(root.playlists.instance())


func GetSongSpacePath(var idx : int) -> String:
	return songs.get_child(idx).path


func SongListHasThis(var path : String) -> int:
	for songspace in songs.get_children():
		if songspace.path == path:
			return songspace.get_index();
	return -1;


func HighlightSong(var SongSpace : HBoxContainer) ->  void:
	SongSpace.get_child(0).set_deferred("custom_styles/panel",HighLightedSong)


func UnHighlightSong(var idx : int) -> void:
	if idx != -1:
		songs.get_child(idx).get_child(0).set_deferred("custom_styles/panel",null)


func FreeHighlightedSongs() -> void:
	#Clearing CTRL highlighted songs
	for HighlightedSong in SongLists.HighlightedSongs:
		songs.get_child( SongListHasThis(HighlightedSong) ).modulate = Color("ffffff")
	SongLists.HighlightedSongs = []


func OnSongSpaceOptions(var idx : int) -> void:
	#No need to check if there is a priorly pressed instance od the SongOptions,
	#since the Input gets disabled anyways
	var x = load("res://src/Scenes/Song/SongOptions/SongOptions.tscn").instance()
	x.rect_position = get_global_mouse_position()
	x.rect_position.x -= SONG_OPTIONS_OFFSET
	x.rect_position.y -= SONG_OPTIONS_OFFSET
	if get_global_mouse_position().y + 200 > OS.get_window_size().y: 
		x.rect_position.y -= 150
	if get_global_mouse_position().x + 200 > OS.get_window_size().x: 
		x.rect_position.x -= 100
	x.SongIdx = idx
	root.add_child(x)


func OnLeftMouseButtonClicked(var idx : int) -> void:
	if idx >= 0:
		if !Input.is_key_pressed(KEY_CONTROL):
			FreeHighlightedSongs()
			#Playing pressed song
			var song_ : Control = songs.get_child(idx)
			var main_idx : int = song_.main_index
			var playlist_idx : int = song_.PlaylistIdx
			#unhighlights the highlighted song when another one has been pressed
			var highlighted_song : int = SongListHasThis(SongLists.CurrentSong)
			if highlighted_song != idx:
				if highlighted_song != -1:
					UnHighlightSong(highlighted_song)
			#highlighting the current song if it has not been already
			HighlightSong(song_)
			SongLists.CurrentPlayList = song_.PlaylistIdx
			root.PlaySong(
				main_idx,
				true,
				Playlist.GetPlaylistName(playlist_idx)
			)
			root.player.set_repeat(false)
			root.SetPlayerImg(1)
		else:
			SongLists.AddHighlightedSongs(songs, idx)


func  _on_SongScroller_resized():
	SongScrollerRect =  SongScroller.get_global_rect()


func GetPlaylistSongAmount() -> int:
	if PlaylistIdx >= 0:
		#Normal Playlists
		return SongLists.Playlists.values()[PlaylistIdx].size();
	elif PlaylistIdx <= -2:
		#Temporary and Smart Playlists
		return SongLists.PressedTempSmartPlaylist.size();
	elif PlaylistIdx == -1:
		#All Songs
		return SongLists.AllSongs.size();
	return -1;


func GetPlaylistCreationDate() -> String:
	var PlaylistName : String = Playlist.GetPlaylistName(PlaylistIdx)
	var TempDate = SaveData.GetDictKeyFromFile(SongLists.AddUserToFilepath(SongLists.FilePaths[9]),PlaylistName,0)
	if TempDate:
		var TimeFormat : TimeFormatter = TimeFormatter.new()
		var Daytime : String = TimeFormat.FormatDayTime(TempDate.hour, TempDate.minute, TempDate.second)
		var Date : String = TimeFormat.FormatDate(TempDate.day,TempDate.month,TempDate.year)
		return Daytime + " " + Date;
	else:
		return "00:00:00 0000 00 000"


func GetPlaylistRuntime() -> String:
	return TimeFormatter.FormatSeconds( Playlist.GetRuntimeInSeconds(PlaylistIdx) ) + "min"


func PlaylistOptionspressed(var IsSmart : bool = false):
	if !SongOptionsRef:
		Global.root.ToggleSongScrollerInput(false)
		var x : Node
		if !IsSmart:
			x = load("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/NormalPlaylist/NormalPlaylistOptions.tscn").instance()
		else:
			x = load("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/SmartPlaylist/SmartPlaylistOptions.tscn").instance()
		SongOptionsRef = x
		var _err = x.connect("tree_exiting",self,"set",["SongOptionsRef",null])
		_err = x.connect("tree_exiting",Global.root,"ToggleSongScrollerInput",[true])
		self.add_child(SongOptionsRef)
		SongOptionsRef.set_owner(self)
		SongOptionsRef.ConnectOptionSignals()
		SongOptionsRef.rect_global_position = PlaylistOptions.rect_global_position
		SongOptionsRef.rect_global_position.x -= SongOptionsRef.rect_size.x / 2.25
		SongOptionsRef.rect_global_position.y -= 10
	else:
		SongOptionsRef.queue_free()


func RenamePlaylist() -> void:
	Global.root.ToggleSongScrollerInput(false)
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	root.add_child(x)
	x.SetTopic("New Playlist Title")
	var _err = x.connect("TextSave",Playlist,"RenamePlaylist",[PlaylistIdx])
	_err = x.connect("tree_exited",self,"UnloadPlaylist")
	_err = x.connect("tree_exited",Global.root,"ToggleSongScrollerInput",[true])


func ExportPlaylist() -> void:
	var PlaylistExportMenu : Node = load("res://src/Scenes/Export/PlaylistExportMenu.tscn").instance()
	Global.root.TopUI.add_child(PlaylistExportMenu)
	PlaylistExportMenu.InitPlaylistExportMenu(PlaylistIdx)


#Header Expanding/Contracting
func OnScrollValueChanged(var val : float) -> void:
	val /= 2.0
	var NewHeight : float
	
	if val > 0.0 and HeaderExpanded:
		ToggleHeaderInfos(false)
	elif val <= 0.0:
		ToggleHeaderInfos(true,MAX_HEADER_SIZE)
	
	
	if !HeaderExpanded:
		NewHeight = MAX_HEADER_SIZE - val
		if NewHeight > MIN_HEADER_SIZE:
			if val - LastScrollValue > 0.0:
				#Scrolling Down
				SetHeaderInfosHeight(
					#If the 1st part is greater zero then the 2nd part defines height,
					#else it's 0, since x * 0 = 0 
					int(val <= HEADER_LABEL_HEIGHT) * (HEADER_LABEL_HEIGHT - val)
				)
				
			else:
				#Scrolling Up
				SetHeaderInfosHeight(
					#If the 1st part is greater zero then the 2nd part defines height,
					#else it's 0, since x * 0 = 0 
					int(HEADER_LABEL_HEIGHT - val >= 0.0) * (HEADER_LABEL_HEIGHT - val)
				)
			var _ptw : PropertyTweener = create_tween().tween_property(
				HeaderCover,
				"rect_min_size:y",
				NewHeight,
				0.1
			)
			#HeaderCover.rect_min_size.y = NewHeight
		else:
			HeaderCover.rect_min_size.y = MIN_HEADER_SIZE
	
	#Saving Last Scroll Value to see Scroll trend (up/down)
	LastScrollValue = val


func ToggleHeaderInfos(var toggle : bool, var min_height : int = -1) -> void:
	for x in Infos:
		for i in x.get_children():
			if i.has_method("set_visible"):
				i.set_visible(toggle)
	HeaderExpanded = toggle
	if min_height != -1: HeaderCover.rect_min_size.y = min_height;


func SetHeaderInfosHeight(var new_height : float) -> void:
	for i in Infos:
		i.rect_min_size.y = new_height


func OnSetCoverPressed():
	var _dialog = Global.root.OpenGeneralFileDialogue(
		self,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"OnCoverSelected",
		[],
		"Image",
		Global.SupportedImgFormats,
		true,
		"Select New Playlist Cover"
	)