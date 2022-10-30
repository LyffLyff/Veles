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
const SongFormats : Array = ["*.mp3","*.ogg","*.flac","*.wav","*.opus"]

#VARIABLES
var LinedEditsChanged : PoolByteArray = []
var MultiplePaths : PoolStringArray = []


func _ready():
	if get_tree().connect("files_dropped",self,"OnFilesDropped"):
		Global.root.Message("CANNOT CONNECT FILES DROPPED SIGNAL TO OnFilesDropped FUNCTION",  SaveData.MESSAGE_ERROR )

	for n in LineEdits.size():
		LinedEditsChanged.push_back(false)
		if LineEdits[n] is TextEdit:
			if LineEdits[n].connect("text_changed",self,"OnLineEditTextChanged",["",n]):
				Global.root.Message("CANNOT CONNECT TEXT CHANGED SIGNAL TO OnLineEditTextChanged FUNCTION",  SaveData.MESSAGE_ERROR )
		elif LineEdits[n] is LineEdit:
			if LineEdits[n].connect("text_changed",self,"OnLineEditTextChanged",[n]):
				Global.root.Message("CANNOT CONNECT TEXT CHANGED SIGNAL TO OnLineEditTextChanged FUNCTION",  SaveData.MESSAGE_ERROR )
	
	#when loading this section it checks
	#if a Global path has been set to
	#automatically set the  path without searching
	if Global.TagPaths.size() != 0:
		for i in Global.TagPaths.size():
			PathEdit.set_text(Global.TagPaths[i])
			MultiplePaths.push_back(Global.TagPaths[i])
			if i + 1 != Global.TagPaths.size():
				_on_AddPath_pressed()
		SetSongPaths(Global.TagPaths)
	Global.TagPaths = []


func OnFilesDropped(var Files : PoolStringArray,var _Screen : int) -> void:
	print(get_global_mouse_position())
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
	
	#Retrieving Paths of Songs
	MultiplePaths.resize(0)
	for n in PathVBOX.get_children():
		MultiplePaths.push_back( n.get_node("LineEdit").get_text() )
	
	#Setting the Changed Tags
	for PathIdx in MultiplePaths.size():
		var z : File = File.new()
		if z.open(MultiplePaths[ PathIdx ],File.READ) != OK:
			#Skipping the Song if it couldn't be opened
			Global.root.Message("COULD NOT OPEN FILE TO BE TAGGED: " + MultiplePaths[ PathIdx ],  SaveData.MESSAGE_ERROR )
			continue;
		
		if FormatChecker.GetMusicFormat( z.get_buffer(1024).hex_encode() ) == -1 and FormatChecker.FileNameFormat(MultiplePaths[ PathIdx ]) == -1:
			#if the Real Format is not supported the loop will be skipped
			#-> to prevent false tags
			Global.root.Message("FILEFORMAT CANNOT BE TAGGED",  SaveData.MESSAGE_ERROR, true )
			continue;
		z.close()
		
		UpdateValuesInAllSongs = false
		if SongLists.AllSongs.has(MultiplePaths[ PathIdx ]):
			#if the Current Song has been added to the AllSongs, certain properties
			#will be changed 
			UpdateValuesInAllSongs = true
			TempMainIdx = AllSongs.GetMainIdx(MultiplePaths[ PathIdx ])
			
		if FileChecker.exists(MultiplePaths[ PathIdx ]):
			Global.root.Message("Setting Tags on: " + MultiplePaths[ PathIdx ], SaveData.MESSAGE_NOTICE)
			
			#ARTIST
			if LinedEditsChanged[ ARTIST ]:
				var NewArtist : String = CreateArtistString()
				Tags.SetArtist(NewArtist, MultiplePaths[ PathIdx ])
				if UpdateValuesInAllSongs:
					#Adding the Changed Artist if not there
					if !SongLists.Artists.has([NewArtist]):
						SongLists.Artists.push_back([NewArtist])
					
					#Setting in AllSongs
					AllSongs.SetSongArtist(NewArtist,TempMainIdx)
			
			#TITLE
			if LinedEditsChanged[ TITLE ]:
				Tags.SetTitle(Title.get_text(),MultiplePaths[ PathIdx ])
				if UpdateValuesInAllSongs:
					AllSongs.SetSongTitleTag(Title.get_text(),TempMainIdx)
			
			#ALBUM
			if LinedEditsChanged[ ALBUM ]:
				Tags.SetAlbum(Album.get_text(),MultiplePaths[ PathIdx ])
			
			#GENRE
			Tags.SetGenre(Genre.get_text(),MultiplePaths[ PathIdx ])
			
			#TRACK NUMBER
			if LinedEditsChanged[ TRACK_NUMBER ]:
				Tags.SetTrackNumber(Track.get_text(), MultiplePaths[ PathIdx ])
			
			#RELEASE_YEAR
			if LinedEditsChanged[ RELEASE_YEAR ]:
				Tags.SetReleaseYear(ReleaseYear.get_text(), MultiplePaths[ PathIdx ])
			
			#COMMENT
			if LinedEditsChanged[ COMMENT ]:
				Tags.SetComment(Comment.get_text(), MultiplePaths[ PathIdx ])
			
			#COVER_DESCRIPTION
			if LinedEditsChanged[ COVER_DESCRIPTION ]:
				Tags.SetCoverDescription(MultiplePaths[ PathIdx ], CoverDescription.get_text())
			
			#Rating
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
				Tags.SetCover(
					cover_path,
					MultiplePaths[ PathIdx ],
					ImageLoader.GetImageMimeType(cover_path)
				)
				if SongLists.AllSongs.has(MultiplePaths[ PathIdx ]):
					var CoverHash : String = str(MultiplePaths[ PathIdx ].hash())
					var x : CoverLoader = CoverLoader.new()
					var y : Directory = Directory.new()
					if y.copy(cover_path,Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + CoverHash + ".png") == OK:
						x.FilteringDuplicateCovers({CoverHash : MultiplePaths[ PathIdx ]})
					else:
						Global.root.Message("COULD NOT COPY NEW COVER",  SaveData.MESSAGE_ERROR )
		else:
			root.Message("Cannot Set Tags on this Fileformat", SaveData.MESSAGE_ERROR, true)
		
		var x : SongLoader = SongLoader.new()
		x.Reload()
		ResetLineEditChanged()
		InitTags(MultiplePaths)
		root.UpdatePlayerInfos()


func _on_SelectSong_pressed():
	var dialog = root.OpenGeneralFileDialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"SetSongPaths",
		[],
		"Song",
		SongFormats,
		false,
		"Select Song"
	)
	$ScrollContainer.set_process_input(false)
	var _err = dialog.connect("Exit",$ScrollContainer,"set_process_input", [true])


func _on_SelectCover_pressed():
	var dialog = root.OpenGeneralFileDialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"SetCoverPath",
		[],
		"Image",
		Global.SupportedImgFormats,
		false,
		"Select Image"
	)
	$ScrollContainer.set_process_input(false)
	var _err = dialog.connect("Exit",$ScrollContainer,"set_process_input", [true])



func SetCoverPath(var paths : PoolStringArray) -> void:
	Cover.set_text(paths[0])


func RenameSong(var old_path : String, var new_path : String, var new_title : String, var PathIdx : int) -> bool:
	var dir : Directory = Directory.new()
	if dir.rename(old_path, new_path) == OK:
		#Current Song
		MultiplePaths[ PathIdx ] = new_path
		if old_path == SongLists.CurrentSong:
			SongLists.CurrentSong = new_path
		#Key in AllSongs
		if SongLists.AllSongs.has(old_path):
			var temp : Array = SongLists.AllSongs.get(old_path)
			temp[0] = new_title
			SongLists.AllSongs.keys()[SongLists.AllSongs.keys().find(old_path,0)] = new_path
			SongLists.AllSongs.values()[SongLists.AllSongs.keys().find(old_path,0)] = temp
			if !SongLists.AllSongs.erase(old_path):
				root.Message("PATH THAT YOU WANTED TO ERASE FROM ALLSONGS IS NOT EXISTENT IN IT: " + old_path, SaveData.MESSAGE_ERROR)
		#Replacing in Playlists
		for n in SongLists.Playlists.size():
			if SongLists.Playlists.values()[n].has(old_path):
				var value : Array = SongLists.Playlists.values()[n].get(old_path)
				if SongLists.Playlists.values()[n].erase(old_path):
					value[0] = AllSongs.GetSongAmount() -1
					SongLists.Playlists.values()[n][new_path] = value
				else:
					root.Message("COULD NOT ERASE KEY IN THE PLAYLISTS", SaveData.MESSAGE_ERROR)
		return true
	else:
		if dir.file_exists(old_path):
			if dir.rename(old_path,new_path) == OK:
				return true;
		return false
 

func InitTags(var ValidPaths : PoolStringArray) -> void:
	#Set Covers
	#Loaded from Scratch so also Songs not in the Covercache can be tagged properly
	var data : PoolByteArray = Tags.ReturnCoverData( ValidPaths[0] )
	if data.size() > 0:
		var img : Image = ImageLoader.CreateImageFromData(data)
		TopCovers.get_child(0).set_deferred( "texture",ImageLoader.CreateTextureFromImage(img) )
	
	#Retrieve Text Tags
	var AllTags : PoolStringArray = []
	AllTags = Tags.new().GetMultipleTags( ValidPaths[0],[0,1,2,3,4,5,6] )
	#Set Tags
	Filename.set_text(ValidPaths[0].get_file().get_basename())
	
	SetArtistLineEdits( AllTags[0] )
	Title.set_text( AllTags[1] )
	Album.set_text( AllTags[2] )
	Genre.set_text( AllTags[3] )
	Comment.set_text( AllTags[4] )
	ReleaseYear.set_text( AllTags[5])
	Track.set_text( AllTags[6])
	Rating.get_line_edit().set_text( str(Tagging.new().GetSongPopularity(ValidPaths[0])[0]) )
	#CoverDescription.set_text( SongTags.GetCoverDescription(ValidPaths[0]) )


func ResetLineEditChanged() -> void:
	for n in LinedEditsChanged.size():
		LinedEditsChanged[n] = false


func SetArtistLineEdits(var Artist_s : String) -> void:
	FreeingArtistLabels()
	var DividedArtists : PoolStringArray = Streams.DivideMultipleArtists(Artist_s)
	for n in DividedArtists.size():
		if n == 0:
			Artist.set_text(DividedArtists[n])
		else:
			_on_AddArtist_pressed()
			ArtistVBOX.get_child(n).get_node("LineEdit").set_text(DividedArtists[n])
			


func _on_AddArtist_pressed():
	var x : HBoxContainer = load("res://src/Scenes/SubOptions/Tagging/AdditionalArtist.tscn").instance()
	if x.get_node("LineEdit").connect("text_changed",self,"OnLineEditTextChanged",[ ARTIST ]):
		root.Message("CONNECTING NEW ARTIST LINEEDIT TO OnLineEditTextChanged function", SaveData.MESSAGE_ERROR)
	if x.get_node("LineEdit").connect("tree_exited",self,"OnLineEditTextChanged",["", ARTIST ]):
		root.Message("CONNECTING ARTIST LINEEDIT TREE EXITED TO OnLineEditTextChanged function", SaveData.MESSAGE_ERROR)
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
	for n in paths:
		if !FileChecker.exists(n):
			return;
	InitTags(paths)
	ResetLineEditChanged()


func OnSongPathManuallyEntered(var ManuallyEnteredPath : String) -> void:
	if !FileChecker.exists(ManuallyEnteredPath):
			return;
	InitTags([ManuallyEnteredPath])
	ResetLineEditChanged()


func SetSongPaths(path_s : PoolStringArray):
	FreeingPathLabels()
	for n in path_s.size():
		if n == 0 and path_s[n].get_extension() in SongFormats:
			PathEdit.set_text(path_s[n])
		else:
			_on_AddPath_pressed()
			PathVBOX.get_child( PathVBOX.get_child_count() - 1 ).get_node("LineEdit").set_text(path_s[n])
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
