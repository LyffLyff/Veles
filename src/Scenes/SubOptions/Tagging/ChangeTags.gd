extends Control


#ENUMS
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

#NODES
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var PathEdit : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Paths/Values/HBoxContainer/LineEdit
onready var PathVBOX : VBoxContainer = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Paths/Values
onready var Filename : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/NameExplorer/SongExplorer
onready var Title : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/NameTag/NameTag
onready var Artist : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Artist/VBoxContainer/HBoxContainer/Artist
onready var ArtistVBOX : VBoxContainer = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Artist/VBoxContainer
onready var Album : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Album/Album
onready var Genre : MenuButton = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/GenreSelection/GenreSelection
onready var Cover : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Cover/Cover/LineEdit
onready var CoverDescription : TextEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Cover/HBoxContainer/CoverDescription
onready var Comment : TextEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Comment/Comment
onready var Track : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/TrackNumber/TrackNumber
onready var ReleaseYear : LineEdit = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/ReleaseYear/ReleaseYear
onready var TopCovers : HBoxContainer = $ScrollContainer/VBoxContainer/ScrollContainer/Covers
onready var Rating : SpinBox = $ScrollContainer/VBoxContainer/MainTags/VBoxContainer/Popularity/RatingEdit
onready var LineEdits : Array = [Filename,Artist,Title,Album,Genre,Comment,ReleaseYear,Track,CoverDescription]

#CONSTANTS
const SongFormats : Array = ["mp3","ogg","flac","wav","opus"]
const dialogue_song_formats : Array = ["*.mp3","*.ogg","*.flac","*.wav","*.opus"]

#VARIABLES
var LinedEditsChanged : PoolByteArray = []
var MultiplePaths : PoolStringArray = []


func _ready():
	if get_tree().connect("files_dropped",self,"OnFilesDropped"):
		Global.root.message("CANNOT CONNECT FILES DROPPED SIGNAL TO OnFilesDropped FUNCTION",  SaveData.MESSAGE_ERROR )

	for n in LineEdits.size():
		LinedEditsChanged.push_back(false)
		if LineEdits[n] is TextEdit:
			if LineEdits[n].connect("text_changed",self,"OnLineEditTextChanged",["",n]):
				Global.root.message("CANNOT CONNECT TEXT CHANGED SIGNAL TO OnLineEditTextChanged FUNCTION",  SaveData.MESSAGE_ERROR )
		elif LineEdits[n] is LineEdit:
			if LineEdits[n].connect("text_changed",self,"OnLineEditTextChanged",[n]):
				Global.root.message("CANNOT CONNECT TEXT CHANGED SIGNAL TO OnLineEditTextChanged FUNCTION",  SaveData.MESSAGE_ERROR )
	
	#when loading this section it checks
	#if a Global path has been set to
	#automatically set the  path without searching
	#if Global.temp_tag_paths.size() != 0:
	#	for i in Global.temp_tag_paths.size():
	#		PathEdit.set_text(Global.temp_tag_paths[i])
	#		MultiplePaths.push_back(Global.temp_tag_paths[i])
	#		if i + 1 != Global.temp_tag_paths.size():
	#			_on_AddPath_pressed()
	SetSongPaths( Global.temp_tag_paths )
	Global.temp_tag_paths = []


func OnFilesDropped(var Files : PoolStringArray,var _Screen : int) -> void:
	if Global.general_dialogue_visible: return;
	var Dis2PathEdit : float = get_global_mouse_position().distance_to(PathEdit.rect_global_position) 
	var Dis2CoverEdit : float = get_global_mouse_position().distance_to(Cover.rect_global_position)
	if Dis2CoverEdit < Dis2PathEdit:
		Cover.set_text(Files[0])
	else:
		SetSongPaths(Files)

func OnLineEditTextChanged(var _NewText : String,var LineEditIdx : int) -> void:
	LinedEditsChanged[LineEditIdx] = true


func _on_SetTag_pressed():
	# FLAG, DATA, Path
	#only sets the specific tag if the LineEdit hasn't been left empty
	var UpdateValuesInAllSongs : bool = false
	var TempMainIdx : int = -1
	var dir : Directory = Directory.new()
	
	#Retrieving Paths of Songs
	MultiplePaths.resize(0)
	for n in PathVBOX.get_children():
		MultiplePaths.push_back( n.get_node("LineEdit").get_text() )
	
	#Setting the Changed Tags
	for PathIdx in MultiplePaths.size():
		var z : File = File.new()
		if z.open(MultiplePaths[ PathIdx ],File.READ) != OK:
			#Skipping the Song if it couldn't be opened
			Global.root.message("File could not be tagged:\n" + MultiplePaths[ PathIdx ],  SaveData.MESSAGE_ERROR, true )
			continue;
		
		if FormatChecker.get_music_format_from_data( z.get_buffer(1024).hex_encode() ) == -1 and FormatChecker.get_music_filename_extension(MultiplePaths[ PathIdx ]) == -1:
			#if the Real Format is not supported the loop will be skipped
			#-> to prevent false tags
			Global.root.message("FILEFORMAT CANNOT BE TAGGED",  SaveData.MESSAGE_ERROR, true )
			continue;
		z.close()
		
		UpdateValuesInAllSongs = false
		if SongLists.AllSongs.has(MultiplePaths[ PathIdx ]):
			#if the Current Song has been added to the AllSongs, certain properties
			#will be changed 
			UpdateValuesInAllSongs = true
			TempMainIdx = AllSongs.get_main_idx(MultiplePaths[ PathIdx ])
			
		if dir.file_exists(MultiplePaths[ PathIdx ]):
			Global.root.message("Setting Tags on: " + MultiplePaths[ PathIdx ], SaveData.MESSAGE_NOTICE)
			
			#ARTIST
			if LinedEditsChanged[ ARTIST ]:
				var NewArtist : String = CreateArtistString()
				Tags.set_artist(NewArtist, MultiplePaths[ PathIdx ])
				if UpdateValuesInAllSongs:
					#Adding the Changed Artist if not there
					if !SongLists.artists.has([NewArtist]):
						SongLists.artists.push_back([NewArtist])
					
					#Setting in AllSongs
					AllSongs.set_song_artist(NewArtist,TempMainIdx)
			
			#TITLE
			if LinedEditsChanged[ TITLE ]:
				Tags.set_title(Title.get_text(),MultiplePaths[ PathIdx ])
				if UpdateValuesInAllSongs:
					AllSongs.set_song_title(Title.get_text(),TempMainIdx)
			
			#ALBUM
			if LinedEditsChanged[ ALBUM ]:
				Tags.set_album(Album.get_text(),MultiplePaths[ PathIdx ])
			
			#GENRE
			Tags.set_genre(Genre.get_text(),MultiplePaths[ PathIdx ])
			
			#TRACK NUMBER
			if LinedEditsChanged[ TRACK_NUMBER ]:
				Tags.set_track_number(Track.get_text(), MultiplePaths[ PathIdx ])
			
			#RELEASE_YEAR
			if LinedEditsChanged[ RELEASE_YEAR ]:
				Tags.set_release_year(ReleaseYear.get_text(), MultiplePaths[ PathIdx ])
			
			#COMMENT
			if LinedEditsChanged[ COMMENT ]:
				Tags.set_comment(Comment.get_text(), MultiplePaths[ PathIdx ])
			
			#COVER_DESCRIPTION
			if LinedEditsChanged[ COVER_DESCRIPTION ]:
				Tags.set_cover_description(MultiplePaths[ PathIdx ], CoverDescription.get_text())
			
			#Rating
			if Rating.get_line_edit().text.is_valid_integer():
				Tagging.new().SetSongPopularity(MultiplePaths[ PathIdx ], Rating.get_value(), -1, "")
			
			#File Explorer Name
			if LinedEditsChanged[0]:
				var new_name : String = Filename.get_text()
				var new_folder_path : String = MultiplePaths[ PathIdx ].get_base_dir()
				var extension : String = MultiplePaths[ PathIdx ].get_extension()
				var new_path : String = new_folder_path +  "/" + new_name + "." + extension
				#needs to reload the Songs since the indexes in the AllSongs Dictionaray would be wrong
				if RenameSong(MultiplePaths[ PathIdx ],new_path, new_name + "." + extension, PathIdx):
					#sets the path string to the new path if renaming was successful
					#to prevent error when trying to set Tags with old nonexistent path
					MultiplePaths[ PathIdx ] = new_path
			
			#Cover
			if Cover.get_text() != "":
				var cover_path : String = Cover.get_text()
				print(MultiplePaths[ PathIdx ])
				Tags.set_cover(
					cover_path,
					MultiplePaths[ PathIdx ],
					ImageLoader.get_image_mime_type(cover_path)
				)
				if SongLists.AllSongs.has(MultiplePaths[ PathIdx ]):
					var CoverHash : String = str(MultiplePaths[ PathIdx ].hash())
					var x : CoverLoader = CoverLoader.new()
					var y : Directory = Directory.new()
					if y.copy(cover_path,Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + CoverHash + ".png") == OK:
						x.filter_duplicate_cover({CoverHash : MultiplePaths[ PathIdx ]})
					else:
						Global.root.message("COULD NOT COPY NEW COVER",  SaveData.MESSAGE_ERROR )
		else:
			root.message("Cannot Set Tags on this Fileformat", SaveData.MESSAGE_ERROR, true)
	
	var x : SongLoader = SongLoader.new()
	x.Reload()
	ResetLineEditChanged()
	SetSongPaths(MultiplePaths)
	InitTags(MultiplePaths)
	root.update_player_infos()


func _on_SelectSong_pressed():
	var dialog = root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"SetSongPaths",
		[],
		"Song",
		dialogue_song_formats,
		false,
		"Select Song"
	)
	$ScrollContainer.set_process_input(false)
	var _err = dialog.connect("exited",$ScrollContainer,"set_process_input", [true])


func _on_SelectCover_pressed():
	var dialog = root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"SetCoverPath",
		[],
		"Image",
		Global.supported_img_extensions,
		false,
		"Select Image"
	)
	$ScrollContainer.set_process_input(false)
	var _err = dialog.connect("exited",$ScrollContainer,"set_process_input", [true])



func SetCoverPath(var paths : PoolStringArray) -> void:
	Cover.set_text(paths[0])


func RenameSong(var old_path : String, var new_path : String, var new_title : String, var PathIdx : int) -> bool:
	var dir : Directory = Directory.new()
	if dir.rename(old_path, new_path) == OK:
		
		# Current Song
		MultiplePaths[ PathIdx ] = new_path
		if old_path == SongLists.current_song:
			SongLists.current_song = new_path
		
		# replacing key in AllSongs
		if SongLists.AllSongs.has(old_path):
			var temp : Array = SongLists.AllSongs.get(old_path)
			temp[0] = new_title
			SongLists.AllSongs.keys()[SongLists.AllSongs.keys().find(old_path,0)] = new_path
			SongLists.AllSongs.values()[SongLists.AllSongs.keys().find(old_path,0)] = temp
			if !SongLists.AllSongs.erase(old_path):
				root.message("PATH THAT YOU WANTED TO ERASE FROM ALLSONGS IS NOT EXISTENT IN IT: " + old_path, SaveData.MESSAGE_ERROR)
		
		# replacing in Playlists
		for n in SongLists.normal_playlists.size():
			if SongLists.normal_playlists.values()[n].has(old_path):
				var value : Array = SongLists.normal_playlists.values()[n].get(old_path)
				if SongLists.normal_playlists.values()[n].erase(old_path):
					value[0] = AllSongs.get_song_amount() -1
					SongLists.normal_playlists.values()[n][new_path] = value
				else:
					root.message("COULD NOT ERASE KEY IN THE PLAYLISTS", SaveData.MESSAGE_ERROR)
		
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
 

func InitTags(var ValidPaths : PoolStringArray) -> void:
	if ValidPaths.size() == 0:
		return
	
	#Set Covers
	#Loaded from Scratch so also Songs not in the Covercache can be tagged properly
	var data : PoolByteArray = Tags.get_embedded_cover( ValidPaths[0] )
	if data.size() > 0:
		var img : Image = ImageLoader.create_image_from_data(data)
		TopCovers.get_child(0).set_deferred( "texture",ImageLoader.image_to_texture(img) )
	else:
		TopCovers.get_child(0).set_deferred( "texture", null)
	
	#Retrieve Text Tags
	var AllTags : PoolStringArray = []
	AllTags = Tags.get_text_tags( ValidPaths[0],[0,1,2,3,4,5,6] )
	#Set Tags
	if AllTags.size() == 0:
		AllTags = ["","","","","","",""]
	
	Filename.set_text(ValidPaths[0].get_file().get_basename())
	SetArtistLineEdits( AllTags[0] )
	Title.set_text( AllTags[1] )
	Album.set_text( AllTags[2] )
	Genre.set_text( AllTags[3] )
	Comment.set_text( AllTags[4] )
	ReleaseYear.set_text( AllTags[5])
	Track.set_text( AllTags[6])
	
	#Song Popularity -> [Rating, Counter, Email]
	var song_rating = Tagging.new().GetSongPopularity(ValidPaths[0])
	if song_rating[0]:
		Rating.get_line_edit().set_text(str(song_rating[0]))
	else:
		Rating.get_line_edit().set_text("n.a.")


func ResetLineEditChanged() -> void:
	for n in LinedEditsChanged.size():
		LinedEditsChanged[n] = false


func SetArtistLineEdits(var Artist_s : String) -> void:
	FreeingArtistLabels()
	var DividedArtists : PoolStringArray = Streams.divide_artists(Artist_s)
	for n in DividedArtists.size():
		if n == 0:
			Artist.set_text(DividedArtists[n])
		else:
			_on_AddArtist_pressed()
			ArtistVBOX.get_child(n).get_node("LineEdit").set_text(DividedArtists[n])
			


func _on_AddArtist_pressed():
	var x : HBoxContainer = load("res://src/Scenes/SubOptions/Tagging/AdditionalArtist.tscn").instance()
	if x.get_node("LineEdit").connect("text_changed",self,"OnLineEditTextChanged",[ ARTIST ]):
		root.message("CONNECTING NEW ARTIST LINEEDIT TO OnLineEditTextChanged function", SaveData.MESSAGE_ERROR)
	if x.get_node("LineEdit").connect("tree_exited",self,"OnLineEditTextChanged",["", ARTIST ]):
		root.message("CONNECTING ARTIST LINEEDIT TREE EXITED TO OnLineEditTextChanged function", SaveData.MESSAGE_ERROR)
	ArtistVBOX.add_child(x)


func CreateArtistString() -> String:
	var CombinedArtists : String = ""
	for n in ArtistVBOX.get_child_count():
		if n == 0:
			CombinedArtists += ArtistVBOX.get_child(0).get_child(1).get_text()
		else:
			if ArtistVBOX.get_child(n).get_child(1).get_text() == "":
				#Skips if the Aritst LineEdits has been left empty
				continue;
			CombinedArtists += ArtistVBOX.get_child(n).get_child(1).get_text()
		
		if n + 1 < ArtistVBOX.get_child_count():
			CombinedArtists += ", "
	return CombinedArtists


func OnSongPathEntered(var paths : PoolStringArray) -> void:
	var dir : Directory = Directory.new()
	for path in paths:
		if !dir.file_exists(path):
			return;
	InitTags(paths)
	ResetLineEditChanged()


func OnSongPathManuallyEntered(var ManuallyEnteredPath : String) -> void:
	InitTags([ManuallyEnteredPath])
	if !Directory.new().file_exists(ManuallyEnteredPath):
		return;
	ResetLineEditChanged()


func SetSongPaths(path_s : PoolStringArray):
	FreeingPathLabels()
	var path_counter : int = 0
	for n in path_s.size():
		if !(path_s[n].get_extension() in SongFormats):
			continue
		if path_counter == 0 :
			PathEdit.set_text(path_s[n])
		else:
			_on_AddPath_pressed()
			PathVBOX.get_child( PathVBOX.get_child_count() - 1 ).get_node("LineEdit").set_text(path_s[n])
		path_counter += 1
	MultiplePaths = path_s
	OnSongPathEntered(path_s)


func FreeingPathLabels() -> void:
	#Resetting Everything regarding the Paths,
	#including added Labels of Multiple Paths of Arrays
	MultiplePaths.resize(0)
	for i in range( 1,PathVBOX.get_child_count()):
		#since I'm removing the child it's always index 1
		var ref = PathVBOX.get_child(1)
		PathVBOX.remove_child(ref)
		ref.queue_free()


func FreeingArtistLabels() -> void:
	for n in range( 1,ArtistVBOX.get_child_count() ):
		#since I'm removing the child it's always index 1
		var ref = ArtistVBOX.get_child(1)
		ArtistVBOX.remove_child(ref)
		ref.queue_free()


func _on_AddPath_pressed():
	var NewPathEdit : HBoxContainer = load("res://src/Scenes/SubOptions/Tagging/AdditionalArtist.tscn").instance()
	NewPathEdit.rect_min_size.y = PathEdit.rect_min_size.y
	PathVBOX.add_child(NewPathEdit)
