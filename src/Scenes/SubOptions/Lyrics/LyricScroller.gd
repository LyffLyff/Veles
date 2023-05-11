extends VBoxContainer

const FONT_CHANGE_STEP : int = 2
const SCROLL_SPEED : int = 40
const MIN_FONT_SIZE : int = 5
const MAX_FONT_SIZE : int = 200
const HIGHLIGHT_MODULATE : String = "ffffff"
const NORMAL_MODULATE : String = "3dffffff"
const VERSE_CONTAINER : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/VerseContainer.tscn")
var TOP_BUFFER : int = 200

var follow_lyrics : bool = true
var current_verse_idx : int = -1	#-1 means the Lyrics are unsynched
var seconds_passed : float = 0.0
var current_font_size : int = 0
var is_synched : bool = false

onready var lyrics_vbox : VBoxContainer = $Background/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/Lyrics
onready var scroll : ScrollContainer = $Background/HBoxContainer/ScrollContainer
onready var update_seconds_passed : Timer = $UpdateSecondsPassed
onready var resync : PanelContainer = $Background/VBoxContainer/HBoxContainer/PanelContainer
onready var bottom_buffer : Control = $Background/HBoxContainer/ScrollContainer/VBoxContainer/BottomBuffer

func _ready():
	load_lyrics()
	set_font_size( SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "LyricsFontSize") )


func _exit_tree():
	# saving the Last Lyrics Font Size
	if current_font_size < MIN_FONT_SIZE:
		current_font_size = MIN_FONT_SIZE
	
	SettingsData.set_setting(
		SettingsData.GENERAL_SETTINGS,
		"LyricsFontSize",
		current_font_size
	)


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if Input.is_physical_key_pressed(KEY_CONTROL):
				#CTRL + SOME_KEY
				if event.button_index == BUTTON_WHEEL_DOWN:
					change_font_size(-1)
				elif event.button_index == BUTTON_WHEEL_UP:
					change_font_size(+1)
			else:
				if event.button_index == BUTTON_WHEEL_DOWN:
					scroll.get_v_scrollbar().value += SCROLL_SPEED
					set_follow_lyrics(false)
				elif event.button_index == BUTTON_WHEEL_UP:
					scroll.get_v_scrollbar().value -= SCROLL_SPEED
					set_follow_lyrics(false)


func find_current_verse() -> void:
	for i in lyrics_vbox.get_child_count():
		if get_current_timestamp_seconds(i) >= MainStream.get_playback_position():
			current_verse_idx = i
			break;
	update_lyrics_position()


func load_lyrics() -> void:
	# resetting Values
	scroll.get_v_scrollbar().value = 0.0
	seconds_passed = 0.0
	resync.set_visible( false )
	
	# setting Lyrics
	var lyrics : Array = Tags.get_lyrics( SongLists.current_song )
	if lyrics.size() == 2 and lyrics[0].size() > 1:
		# SYNCHED
		# 0: PoolStringArray of Verses
		# 1: PoolRealArray of Corresponding Timestamps
		is_synched = true
		if lyrics[0].size() == lyrics[1].size():
			for i in lyrics[0].size():
				var new_verse = VERSE_CONTAINER.instance()
				lyrics_vbox.add_child(new_verse)
				new_verse.get_child(0).set_align(SettingsData.get_setting(SettingsData.SONG_SETTINGS, "LyricsTextAlignment"))
				new_verse.get_child(1).set_visible(SettingsData.get_setting(SettingsData.SONG_SETTINGS, "LyricsVisibleTimestamps"))
				new_verse.modulate = NORMAL_MODULATE
				new_verse.connect("gui_input",self,"on_Verse_input_event",[i])
				new_verse.get_child(0).set_text(lyrics[0][i])
				new_verse.get_child(1).set_text(str(lyrics[1][i]).pad_decimals(2))
		find_current_verse()
		update_seconds_passed.start(0.0)
		move_lyrics_to(current_verse_idx)
	elif lyrics.size() > 0:
		is_synched = false
		# UNSYNCHED
		var unsynched_lyrics : String = ""
		if lyrics[0] is PoolStringArray:
			unsynched_lyrics = lyrics[0][0]
		elif lyrics[0] is String:
			unsynched_lyrics = lyrics[0]
		
		var x = VERSE_CONTAINER.instance()
		lyrics_vbox.add_child(x)
		x.get_child(0).set_align(SettingsData.get_setting(SettingsData.SONG_SETTINGS, "LyricsTextAlignment"))
		x.get_child(1).set_visible(SettingsData.get_setting(SettingsData.SONG_SETTINGS, "LyricsVisibleTimestamps"))
		x.get_child(0).set_text(unsynched_lyrics)
		x.get_child(1).hide()
	else:
		# No Lyrics
		current_verse_idx = -1
		update_seconds_passed.stop()
	lyrics_vbox.update()


func on_Verse_input_event(var event, var verse_idx : int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if current_verse_idx != -1:
					if current_verse_idx - 1 != -1:
						lyrics_vbox.get_child(current_verse_idx - 1).modulate = NORMAL_MODULATE
					MainStream.seek( float(lyrics_vbox.get_child(verse_idx).get_child(1).get_text()) )
					current_verse_idx = verse_idx
					# -2 soo the Verse will be actually played and not just skipped immediately
					# SecondsCounter = current_lyrics[current_verse_idx]["seconds"]
					set_follow_lyrics(true)
					update_lyrics_position()


func change_font_size(var direction : int) -> void:
	# Since the Verses are all instances of each other 
	# changing the font size of one changes the font size of all
	# Verses and Timestamps
	if lyrics_vbox.get_child_count() > 0:
		var dyn_font : DynamicFont = lyrics_vbox.get_child(0).get_child(0).get_font("font")
		var new_font_size : int = dyn_font.size + (FONT_CHANGE_STEP * direction)
		if new_font_size in range(MIN_FONT_SIZE,MAX_FONT_SIZE):
			dyn_font.size = new_font_size
		current_font_size = new_font_size
		dyn_font.update_changes()
		update_lyrics_position()


func set_font_size(var font_size : int) -> void:
	# always setting current font size even if there are no lyrics
	current_font_size = font_size
	if lyrics_vbox.get_child_count() > 0:
		var dyn_font : DynamicFont = lyrics_vbox.get_child(0).get_child(0).get_font("font")
		dyn_font.size = font_size
		dyn_font.update_changes()
		update_lyrics_position()


func update_lyrics_position() -> void:
	if current_verse_idx != -1 and current_verse_idx  < lyrics_vbox.get_child_count():
		lyrics_vbox.get_child(current_verse_idx).modulate = HIGHLIGHT_MODULATE
		if current_verse_idx > 0:
			lyrics_vbox.get_child(current_verse_idx - 1).modulate = NORMAL_MODULATE
		move_lyrics_to(current_verse_idx)


func move_lyrics_to(var child_idx : int) -> void:
	if child_idx < lyrics_vbox.get_child_count() and child_idx >= 0:
		if follow_lyrics:
			Global.request_fps_change(60)
			var tw : SceneTreeTween = create_tween()
			var dst_value : float = lyrics_vbox.get_child(child_idx).rect_position.y - (TOP_BUFFER * self.get_rect().size.y / OS.get_screen_size().y)  + bottom_buffer.rect_size.y
			var _ptw : PropertyTweener = tw.tween_property(scroll.get_v_scrollbar(), "value", dst_value, 0.3)
			yield(tw,"finished")
			Global.request_fps_change(4)


func get_current_timestamp_seconds(var child_idx : int) -> float:
	return float( lyrics_vbox.get_child( child_idx ).get_child(1).get_text() )


func set_follow_lyrics(var toggle : bool) -> void:
	if is_synched:
		var tw : SceneTreeTween = create_tween()
		resync.set_visible(!toggle)
		var _ptw : PropertyTweener = tw.tween_property(resync, "modulate:a", float(!toggle), 0.2)
	follow_lyrics = toggle


func update() -> void:
	for i in lyrics_vbox.get_child_count():
		lyrics_vbox.get_child(i).queue_free()
	load_lyrics()


func _on_UpdateSecondsPassed_timeout():
	seconds_passed = MainStream.get_playback_position()
	on_lyrics_timer_timeout()


func on_lyrics_timer_timeout():
	if current_verse_idx < lyrics_vbox.get_child_count() and current_verse_idx != -1:
		var timestamp_seconds : float = get_current_timestamp_seconds(current_verse_idx)
		if timestamp_seconds <= seconds_passed:
			if current_verse_idx < lyrics_vbox.get_child_count():
				update_lyrics_position()
				current_verse_idx += 1


func _on_Resync_pressed():
	set_follow_lyrics(true)
	update_lyrics_position()


func _on_LyricScroller_resized():
	update_lyrics_position()
