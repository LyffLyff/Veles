extends HBoxContainer


#NODES
onready var VerseTools : VBoxContainer = $VBoxContainer/ToolPanel/HBoxContainer/VerseTools
onready var TimeStampTools : VBoxContainer = $VBoxContainer/ToolPanel/HBoxContainer/TimeStampTools
onready var TimeStampVBox : VBoxContainer = $VBoxContainer/ScrollContainer/HBoxContainer/TimeStampVBox
onready var VerseVBox : VBoxContainer = $VBoxContainer/ScrollContainer/HBoxContainer/VerseVBox
onready var ProjectTitle : LineEdit = $VBoxContainer/Title
onready var LRCTags : VBoxContainer = $VBoxContainer/LRCTags
	#DOCUMENT OPTIONS
onready var Save : TextureButton = $VBoxContainer/PanelContainer/DocOptions/Save
onready var SaveAsButton : TextureButton = $VBoxContainer/PanelContainer/DocOptions/SaveAs
onready var EmbedInSong : TextureButton = $VBoxContainer/PanelContainer/DocOptions/EmbedInFile

#PRELOADS
const TimeStampContainer : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/LyricsEditor/TimeStampContainer.tscn")
const VerseContainer : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/LyricsEditor/VerseContainer.tscn")

#CONSTANTS
const LRCFileExtension : String = ".lrc"
const VPLFileExtension : String = ".vpl"

#VARIABLES
var ProjectPath : String = ""
var ProjectUpToDate : bool = true


func _unhandled_key_input(event):
	if event.is_pressed():
		if Input.is_key_pressed(KEY_CONTROL):
			match event.scancode:
				KEY_S:
					#Saves the Project, with shift it is "Save As"
					OnSaveLyricsProject( Input.is_key_pressed(KEY_SHIFT) )
		else:
			if Input.is_key_pressed(KEY_V):
				#All Actions for Verses
				match event.scancode:
					KEY_A:
						OnAddVersePressed()
					KEY_D:
						OnCutVersePressed()
			elif Input.is_key_pressed(KEY_T):
				#All Actions for Timestamps
				match event.scancode:
					KEY_A:
						OnAddTimeStampPressed()
					KEY_D:
						OnCutTimeStampPressed()
			elif Input.is_key_pressed(KEY_P):
				OnAddTimeStampPressed()
				TimeStampVBox.get_child( 
					TimeStampVBox.get_child_count() - 1
				).TimeStamp.set_text(
					str( 
						MainStream.get_playback_position() 
					).pad_decimals(2)
				)


func _ready():
	var _err = TimeStampTools.AddTimeStamp.connect("pressed",self,"OnAddTimeStampPressed")
	_err = TimeStampTools.CutTimeStamp.connect("pressed",self,"OnCutTimeStampPressed")
	_err = VerseTools.AddVerse.connect("pressed",self,"OnAddVersePressed")
	_err = VerseTools.CutVerse.connect("pressed",self,"OnCutVersePressed")


func NReady(var PrjctPth : String = "") -> void:
	if PrjctPth != "":
		match PrjctPth.get_extension():
			"lrc":
				CreateFromLRC(PrjctPth)
			"mp3":
				CreateFromSong( Tags.GetLyrics(PrjctPth) )
			"vlp":
				ProjectPath = PrjctPth
				LoadProject()
	ProjectUpToDate = true
	AddProjectAsEdited(ProjectPath)


func LoadProject() -> void:
	var ProjectData : Array = SaveData.Load(ProjectPath)
	
	#title
	ProjectTitle.set_text( ProjectData[0] )
	
	#LRC Tags
	LRCTags.Artist.set_text(ProjectData[3][0])
	LRCTags.Album.set_text(ProjectData[3][1])
	LRCTags.Title.set_text(ProjectData[3][2])
	LRCTags.Author.set_text(ProjectData[3][3])
	LRCTags.SongLength.set_text(ProjectData[3][4])
	LRCTags.Language.set_text(ProjectData[3][5])
	LRCTags.CreatorOfFile.set_text(ProjectData[3][6])
	
	#Verses
	InitVerses(ProjectData[1])
	
	#Timestamps
	InitTimestamps(ProjectData[2])


func InitVerses(var Verses : PoolStringArray) -> void:
	for i in Verses.size():
		OnAddVersePressed()
		VerseVBox.get_child(i).VerseText.set_text( Verses[i] )
		
		#Resizing the Verse TextEdit if the Verse  is Mutliline
		VerseVBox.get_child(i).OnVerseTextChanged()


func InitTimestamps(var Timestamps : PoolRealArray) -> void:
	for i in Timestamps.size():
		OnAddTimeStampPressed()
		TimeStampVBox.get_child(i).TimeStamp.set_text( str( Timestamps[i] ) )


func CreateFromLRC(var LRCFilePath : String) -> void:
	#Retreive Encoded Data
	var EncodedProjectData : String = SaveData.LoadAsText(LRCFilePath)
	var DecodedLRCFile : Array = LRC.new().DecodeLRCFile( EncodedProjectData )
	
	#Info
	ProjectTitle.set_text( ProjectPath.get_file().replace(".lrc","") )
	LRCTags.Artist.set_text(DecodedLRCFile[0].values()[0])
	LRCTags.Album.set_text(DecodedLRCFile[0].values()[1])
	LRCTags.Title.set_text(DecodedLRCFile[0].values()[2])
	LRCTags.Author.set_text(DecodedLRCFile[0].values()[3])
	LRCTags.SongLength.set_text(DecodedLRCFile[0].values()[4])
	LRCTags.Language.set_text(DecodedLRCFile[0].values()[5])
	LRCTags.CreatorOfFile.set_text(DecodedLRCFile[0].values()[6])
	
	#Verses
	for i in DecodedLRCFile[1].size():
		OnAddVersePressed()
		VerseVBox.get_child(i).VerseText.set_text( DecodedLRCFile[1][i] )
		
		#Resizing the Verse TextEdit if the Verse  is Mutliline
		VerseVBox.get_child(i).OnVerseTextChanged()
	#TimeStamps
	for i in DecodedLRCFile[2].size():
		OnAddTimeStampPressed()
		TimeStampVBox.get_child(i).TimeStamp.set_text( str( DecodedLRCFile[2][i] ) )


func CreateFromAPIResponse(var APIResponse : Array) -> void:
	#Freeing prior Verses/Timestamps
	for Verse in VerseVBox.get_children():
		Verse.queue_free()
	for Timestamp in TimeStampVBox.get_children():
		Timestamp.queue_free()
	
	#Creating Project from given data
	for i in APIResponse.size():
		OnAddVersePressed()
		OnAddTimeStampPressed()
		VerseVBox.get_child(i).VerseText.set_text(
			APIResponse[i]["lyrics"]
		)
		VerseVBox.get_child(i).OnVerseTextChanged()
		TimeStampVBox.get_child(i).TimeStamp.set_text(
			str( APIResponse[i]["seconds"] )
		)


func CreateFromSong(var Lyrics : Array) -> void:
	match Lyrics.size():
		1:
			InitVerses(Lyrics[0])
		2:
			InitVerses(Lyrics[0])
			InitTimestamps(Lyrics[1])


func OnSaveLyricsProject(var SaveAs : bool = false):
	#VLP = Veles Lyrics Project
	#Structure = Array
	#[Title, Verses, Timestamps, [Artist, Album, Title, Author, Length, Language, Creator of File] ]
	var Title : String = ProjectTitle.get_text()
	var VLPFiledata : Array = [
		Title,
		GetAllVerses(),
		GetAllTimeStamps(),
		[
			LRCTags.Artist.get_text(),
			LRCTags.Album.get_text(),
			LRCTags.Title.get_text(),
			LRCTags.Author.get_text(),
			LRCTags.SongLength.get_text(),
			LRCTags.Language.get_text(),
			LRCTags.CreatorOfFile.get_text()
		]
	]
	
	if FileChecker.exists( ProjectPath ) and !SaveAs:
		#The Project already exists, the PreExisting File will
		#be overriden with the new Data
		SaveData.Save(ProjectPath.replace("user://", OS.get_user_data_dir() ), VLPFiledata )
		ProjectUpToDate = true
	else:
		var x = load("res://src/scenes/General/GeneralFileDialogue.tscn").instance()
		self.add_child(x)
		x.NReady(FileDialog.MODE_SAVE_FILE ,FileDialog.ACCESS_USERDATA, "Lyrics",["*.vlp"], true, "Save Project As",Title)
		x.Dialog.current_dir = Global.GetCurrentUserDataFolder() + "/Lyrics/Projects"
		var _err = x.connect("SelectionMade", SaveData, "Save", [VLPFiledata])
		if SaveAs:
			_err = x.connect("SelectionMade", self, "set", ["ProjectPath"])
		_err = x.connect("SelectionMade", self, "AddProjectAsEdited")
		_err = x.connect("Saved", self, "set", ["ProjectUpToDate",true])


func AddProjectAsEdited(var NewProjectPath : String) -> void:
	var EditedProjects : Array = SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"LastEditedVLPProjects")
	if !EditedProjects.has(NewProjectPath):
		EditedProjects.push_back(NewProjectPath)
	else:
		EditedProjects.remove(EditedProjects.find(NewProjectPath))
		EditedProjects.push_front(NewProjectPath)
	SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"LastEditedVLPProjects",EditedProjects)


func ExportToLRC() -> void:
	var Title : String = ProjectTitle.get_text()
	
	var LRCFileData : String = LRC.new().EncodeLRCFile(
		GetAllVerses(),
		GetAllTimeStamps(),
		LRCTags.Artist.get_text(),
		LRCTags.Album.get_text(),
		LRCTags.Title.get_text(),
		LRCTags.Author.get_text(),
		LRCTags.SongLength.get_text(),
		LRCTags.Language.get_text(),
		LRCTags.CreatorOfFile.get_text()
	)
	
	var x = load("res://src/scenes/General/GeneralFileDialogue.tscn").instance()
	self.add_child(x)
	x.NReady(FileDialog.MODE_SAVE_FILE ,FileDialog.ACCESS_FILESYSTEM, "ExportLRC",["*.lrc"], true, "Export Project to LRC File")
	var _err = x.connect("SelectionMade", Exporter.new(), "ToLRC", [LRCFileData])


func _on_PasteFromClipboard_pressed():
	#pastes a text from the clipboard and puts each line (divided by newline) in a new verse
	var clipboard_text : PoolStringArray = OS.get_clipboard().split("\n")
	for i in clipboard_text.size():
		OnAddVersePressed()
		VerseVBox.get_child( VerseVBox.get_child_count() - 1 ).VerseText.text = clipboard_text[i]


#TIMESTAMPS
func OnAddTimeStampPressed() -> void:
	ProjectUpToDate = false
	var NewTimeStamp = TimeStampContainer.instance()
	TimeStampVBox.add_child(NewTimeStamp)
	var _err = NewTimeStamp.connect("TimestampChanged",self,"set",["ProjectUpToDate",false])
	
	if VerseVBox.get_child_count() >= TimeStampVBox.get_child_count():
		#a new timestamp will be given the height of the Verse on creation if needed
		NewTimeStamp.rect_min_size.y = VerseVBox.get_child( NewTimeStamp.get_index() ).rect_size.y


func OnCutTimeStampPressed(var idx : int = -1):
	ProjectUpToDate = false
	if idx == -1:
		#if the given index is invalid the lowest timestamp will be deleted
		if TimeStampVBox.get_child_count() == 0:
			return
		idx = TimeStampVBox.get_child_count() - 1
	TimeStampVBox.get_child(idx).queue_free()


#VERSES
func OnAddVersePressed() -> void:
	ProjectUpToDate = false
	var NewVerse = VerseContainer.instance()
	var _err = NewVerse.connect("VerseRectChanged",self,"OnVerseRectChanged")
	_err = NewVerse.connect("VerseTextChanged",self,"set",["ProjectUpToDate",false])
	VerseVBox.add_child( NewVerse )


func OnCutVersePressed(var idx = -1) -> void:
	ProjectUpToDate = false
	if idx == -1:
		if VerseVBox.get_child_count() == 0:
			return
		idx = VerseVBox.get_child_count() - 1
	VerseVBox.get_child(idx).queue_free()


func OnVerseRectChanged(var VerseIdx : int, var NewHeight : int) -> void:
	if VerseIdx < TimeStampVBox.get_child_count():
		TimeStampVBox.get_child(VerseIdx).rect_min_size.y = NewHeight


func OnReturnPressed():
	if !ProjectUpToDate:
		#Asking if they want to leave without saving
		var x : Node = load("res://src/Scenes/General/QuestionDialog.tscn").instance()
		Global.root.add_child(x)
		x.NReady( "Leave Project without Saving?" )
		var _err = x.connect("Yes",Global.root,"LoadOptions",[6,true])
	else:
		#If Porject is up to Date it won't display Notice
		Global.root.LoadOptions(6,true)

func GetLyricsProjectPath(var Title : String) -> String:
	return OS.get_user_data_dir() + "/Lyrics/Projects/" + Title + VPLFileExtension


func GetAllVerses() -> PoolStringArray:
	var Verses : PoolStringArray = []
	for VerseContainer in VerseVBox.get_children():
		Verses.push_back( VerseContainer.VerseText.get_text())
	return Verses


func GetAllTimeStamps() -> PoolRealArray:
	var TimeStamps : PoolRealArray = []
	for TimeStampContainer in TimeStampVBox.get_children():
		TimeStamps.push_back( float( TimeStampContainer.TimeStamp.get_text() ) )
	return TimeStamps;


func OnTitleEntered(var _NewTitle : String):
	ProjectUpToDate = false


func OnDeleteProjectFilePressed():
	#Deleting the Current Project and returning to the Project Selection screen
	if Directory.new().remove(ProjectPath) != OK:
		Global.root.Message("REMOVING PROJECT FILE: " + ProjectPath,  SaveData.MESSAGE_ERROR )
	OnReturnPressed()


func OnEmbedInFilePressed():
	var Verses : PoolStringArray = GetAllVerses()
	var Timestamps : PoolRealArray = GetAllTimeStamps()
	var IsSynchronized : bool = Verses.size() == Timestamps.size()
	var x = load("res://src/scenes/General/GeneralFileDialogue.tscn").instance()
	Global.root.add_child(x)
	x.NReady(FileDialog.MODE_OPEN_FILES ,FileDialog.ACCESS_FILESYSTEM, "Song",["*.mp3","*.ogg","*.wav"], false, "Embed In Song")
	var _err = x.connect("SelectionMade", Tags, "SetLyrics", [IsSynchronized, Verses, Timestamps])


func OnOpenInFileManagerPressed():
	var NPath : String = ProjectPath.replace(ProjectPath.get_file(),"").replace("user://",OS.get_user_data_dir() + "/")
	if OS.shell_open( 	NPath ) != OK:
		Global.root.Message("OPENING PROJECT DIRECTORY: " + NPath,  SaveData.MESSAGE_ERROR )


func OnSaveAs() -> void:
	OnSaveLyricsProject(true)


func OnAPIFetchpressed():
	var APIFetch : Node = load("res://src/Scenes/SubOptions/Lyrics/APIFetch.tscn").instance()
	var _err = APIFetch.connect("OverwriteProject",self,"CreateFromAPIResponse")
	get_parent().add_child(APIFetch)

