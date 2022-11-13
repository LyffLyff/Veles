extends VBoxContainer


#NODES
onready var LyricVBox : VBoxContainer = $Background/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/Lyrics
onready var Scroll : ScrollContainer = $Background/HBoxContainer/ScrollContainer
onready var UpdateSecondsPassed : Timer = $UpdateSecondsPassed
onready var Resync : TextureButton = $Background/VBoxContainer/HBoxContainer/Resync
onready var BottomBuffer : Control = $Background/HBoxContainer/ScrollContainer/VBoxContainer/BottomBuffer

#CONSTANTS
const FONT_CHANGE_STEP : int = 2
const SCROLL_SPEED : int = 40
const MIN_FONT_SIZE : int = 5
const MAX_FONT_SIZE : int = 200
const HighlightModulate : String = "ffffff"
const NormalModulate : String = "3dffffff"

#VARIABLES
var FollowLyrics : bool = true
var CurrentVerseIdx : int = -1	#-1 means the Lyrics are unsynched
var TopBuffer : int = 200
var SecondsPassed : float = 0.0
var CurrentFontSize : int = 0
var IsSynched : bool = false

#PRELOADS
const VerseContainer : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/VerseContainer.tscn")


func _ready():
	LoadLyrics()
	SetFontSize( SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "LyricsFontSize") )


func _exit_tree():
	#Saving the Last Lyrics Font Size
	if CurrentFontSize < MIN_FONT_SIZE:
		CurrentFontSize = MIN_FONT_SIZE
	
	SettingsData.SetSetting(
		SettingsData.GENERAL_SETTINGS,
		"LyricsFontSize",
		CurrentFontSize
	)


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if Input.is_physical_key_pressed(KEY_CONTROL):
				#CTRL + SOME_KEY
				if event.button_index == BUTTON_WHEEL_DOWN:
					ChangeFontSize(-1)
				elif event.button_index == BUTTON_WHEEL_UP:
					ChangeFontSize(+1)
			else:
				if event.button_index == BUTTON_WHEEL_DOWN:
					Scroll.get_v_scrollbar().value += SCROLL_SPEED
					SetFollowLyrics(false)
				elif event.button_index == BUTTON_WHEEL_UP:
					Scroll.get_v_scrollbar().value -= SCROLL_SPEED
					SetFollowLyrics(false)


func OnVerseInputEvent(var event, var VerseIdx : int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if CurrentVerseIdx != -1:
					if CurrentVerseIdx - 1 != -1:
						LyricVBox.get_child(CurrentVerseIdx - 1).modulate = NormalModulate
					MainStream.seek( float(LyricVBox.get_child(VerseIdx).get_child(1).get_text()) )
					CurrentVerseIdx = VerseIdx
					#-2 soo the Verse will be actually played and not just skipped immediately
					#SecondsCounter = CurrentLyrics[CurrentVerseIdx]["seconds"]
					SetFollowLyrics(true)
					UpdateLyricsPosition()


func OnUpdateSecondsPassedTimeout():
	SecondsPassed = MainStream.get_playback_position()
	OnLyricsTimerTimeout()


func FindCurrentVerse() -> void:
	for i in LyricVBox.get_child_count():
		if GetTimeStampSeconds(i) >= MainStream.get_playback_position():
			CurrentVerseIdx = i
			break;
	UpdateLyricsPosition()


func LoadLyrics() -> void:
	#Resetting Values
	Scroll.get_v_scrollbar().value = 0.0
	SecondsPassed = 0.0
	Resync.set_visible( false )
	
	#Setting Lyrics
	var Lyrics : Array = Tags.GetLyrics( SongLists.CurrentSong )
	if Lyrics.size() == 2 and Lyrics[0].size() > 1:
		#SYNCHED
		#0: PoolStringArray of Verses
		#1: PoolRealArray of Corresponding Timestamps
		IsSynched = true
		if Lyrics[0].size() == Lyrics[1].size():
			for i in Lyrics[0].size():
				var NewVerse = VerseContainer.instance()
				LyricVBox.add_child( NewVerse )
				NewVerse.get_child(0).set_align( SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "LyricsTextAlignment") )
				NewVerse.get_child(1).set_visible( SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "LyricsVisibleTimestamps") )
				NewVerse.modulate = NormalModulate
				NewVerse.connect("gui_input",self,"OnVerseInputEvent",[i])
				NewVerse.get_child(0).set_text( Lyrics[0][i] )
				NewVerse.get_child(1).set_text( str( Lyrics[1][i] ) )
		FindCurrentVerse()
		UpdateSecondsPassed.start(0.0)
		MoveLyricsTo(CurrentVerseIdx)
	elif Lyrics.size() > 0:
		IsSynched = false
		#UNSYNCHED
		var UnsynchedLyrics : String = ""
		if Lyrics[0] is PoolStringArray:
			UnsynchedLyrics = Lyrics[0][0]
		elif Lyrics[0] is String:
			UnsynchedLyrics = Lyrics[0]
		
		var x = VerseContainer.instance()
		LyricVBox.add_child(x)
		x.get_child(0).set_align( SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "LyricsTextAlignment") )
		x.get_child(1).set_visible( SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "LyricsVisibleTimestamps") )
		x.get_child(0).set_text(UnsynchedLyrics)
		x.get_child(1).hide()
	else:
		#No Lyrics
		CurrentVerseIdx = -1
		UpdateSecondsPassed.stop()
	LyricVBox.update()


func Update() -> void:
	for i in LyricVBox.get_child_count():
		LyricVBox.get_child(i).queue_free()
	LoadLyrics()


func ChangeFontSize(var direction : int) -> void:
	#Since the Verses are all instances of each other 
	#changing the font size of one changes the font size of all
	#Verses and Timestamps
	if LyricVBox.get_child_count() > 0:
		var DynFont : DynamicFont = LyricVBox.get_child(0).get_child(0).get_font("font")
		var NewFontSize : int = DynFont.size + (FONT_CHANGE_STEP * direction)
		if NewFontSize in range(MIN_FONT_SIZE,MAX_FONT_SIZE):
			DynFont.size = NewFontSize
		CurrentFontSize = NewFontSize
		DynFont.update_changes()
		UpdateLyricsPosition()


func SetFontSize(var font_size : int) -> void:
	#Always setting current font size even if there are no lyrics
	CurrentFontSize = font_size
	if LyricVBox.get_child_count() > 0:
		var DynFont : DynamicFont = LyricVBox.get_child(0).get_child(0).get_font("font")
		DynFont.size = font_size
		DynFont.update_changes()
		UpdateLyricsPosition()


func UpdateLyricsPosition() -> void:
	if CurrentVerseIdx != -1 and CurrentVerseIdx  < LyricVBox.get_child_count():
		LyricVBox.get_child(CurrentVerseIdx).modulate = HighlightModulate
		if CurrentVerseIdx > 0:
			LyricVBox.get_child(CurrentVerseIdx - 1).modulate = NormalModulate
		MoveLyricsTo(CurrentVerseIdx)


func MoveLyricsTo(var ChildIdx : int) -> void:
	if ChildIdx < LyricVBox.get_child_count():
		if FollowLyrics:
			Global.RequestFPSChange(60)
			var tw : SceneTreeTween = create_tween()
			var DstValue : float = LyricVBox.get_child(ChildIdx).rect_position.y - ( TopBuffer * self.get_rect().size.y / OS.get_screen_size().y )  + BottomBuffer.rect_size.y
			var _ptw : PropertyTweener = tw.tween_property(Scroll.get_v_scrollbar(), "value", DstValue, 0.3)
			yield(tw,"finished")
			Global.RequestFPSChange(4)


func GetTimeStampSeconds(var ChildIdx : int) -> float:
	return float( LyricVBox.get_child( ChildIdx ).get_child(1).get_text() )


func OnLyricsTimerTimeout():
	if CurrentVerseIdx < LyricVBox.get_child_count() and CurrentVerseIdx != -1:
		var TimestampSeconds : float = GetTimeStampSeconds(CurrentVerseIdx)
		if TimestampSeconds <= SecondsPassed:
			if CurrentVerseIdx < LyricVBox.get_child_count():
				UpdateLyricsPosition()
				CurrentVerseIdx += 1


func SetFollowLyrics(var toggle : bool) -> void:
	if IsSynched:
		var tw : SceneTreeTween = create_tween()
		Resync.set_visible(!toggle)
		var _ptw : PropertyTweener = tw.tween_property(Resync, "modulate:a", float(!toggle), 0.2)
	FollowLyrics = toggle


func OnResyncPressed():
	SetFollowLyrics(true)
	UpdateLyricsPosition()


func _on_LyricScroller_resized():
	UpdateLyricsPosition()
