extends ScrollContainer

signal toggle_process
signal space_pressed
signal space_rightclick
signal space_entered
signal space_exited
signal panel_visible

const VBOX_SEPARATION : int = 3
const SONGSPACE_HEIGHT : int = 41

var idx : int = -1
var curr_idx : int = -1
var ignore_mouse_input : bool = true
var mouse_pos : Vector2
var is_filtering : bool = false

onready var song_slider : VScrollBar = get_v_scrollbar()
onready var playlist_root : Control = null

# connects to each songspace and toggle its process to detect the mouse
# disable all processes when leaving this ScrollContainer to prevent misinput
func init_song_scroller():
	# disabling Smooth scroll for a while
	ignore_mouse_input = false
	self.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	
	# V-Scrollbar
	song_slider.set_script(load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd"))
	song_slider.set_h_size_flags(SIZE_SHRINK_CENTER)
	song_slider._ready()
	if song_slider.connect("scrollbar_released", self, "block_song_highlighter",[true]):
		Global.root.message("Cannot Connect scrollbar_released to block_song_highlighter function",  SaveData.MESSAGE_ERROR )
	if song_slider.connect("scrollbar_pressed", self, "block_song_highlighter",[false]):
		Global.root.message("Cannot Connect scrollbar_pressed to block_song_highlighter function",  SaveData.MESSAGE_ERROR )
	if song_slider.connect("mouse_entered",song_slider,"grab_click_focus"):
		Global.root.message("CONNECTING SONG SCROLLBAR TO VScrollbarFocusser FUNCTION",  SaveData.MESSAGE_ERROR )
	if song_slider.connect("mouse_entered",self,"emit_signal",["space_exited",curr_idx]):
		Global.root.message("CONNECTING SONG SCROLLBAR TO VScrollbarFocusser FUNCTION",  SaveData.MESSAGE_ERROR )
	
	# ProcessToggler
	if self.connect("panel_visible", playlist_root.song_highlighter, "set_visible"):
		Global.root.message("CONNECTING TOGGLE PROCESS TO SONGSCROLLER VISIBILITY",  SaveData.MESSAGE_ERROR )


func _notification(what):
	# disabling Processes when focus on the wondpw has been lost
	if what == MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
		# exiting the Current Space, so it won't be falsely focused
		emit_signal("space_exited",curr_idx)


func _input(var event):
	if event is InputEventMouseMotion:
		mouse_pos = event.global_position
	elif event is InputEventMouseButton:
		if ignore_mouse_input:
			return;
		if event.is_pressed():
			idx = calc_idx()
			if event.button_index == BUTTON_LEFT:
				if idx >= 0:
						# checking if inside  of Rect of Songs 
						if get_parent().get_global_rect().has_point(mouse_pos):
							# preventing a click if its just next  to the Scrollbar
							if get_global_rect().position.x + get_global_rect().size.x >= mouse_pos.x + 25:
								if (Global.pressed_playlist_idx < -2 and Global.pressed_playlist_idx != SongLists.current_playlist_idx) or Global.pressed_playlist_idx == -2:
									SongLists.current_temporary_playlist = SongLists.pressed_temporary_playlist
								call_deferred("emit_signal","space_pressed",real_index(idx))
			elif event.button_index == BUTTON_RIGHT:
				if self.get_global_rect().has_point( get_global_mouse_position() ) and idx >= 0:
					var r_idx : int = real_index(idx)
					if r_idx >= 0:
						call_deferred("emit_signal","space_rightclick", r_idx)


func _physics_process(_delta):
	# if the VBox and the ScrollContainer have this point
	if get_child(0).get_global_rect().has_point(mouse_pos) and self.get_global_rect().has_point(mouse_pos) and mouse_pos.x  + 40 < get_global_rect().size.x + get_global_rect().position.x:
		if playlist_root.songs.get_child_count() > 0 and real_index(calc_idx()) < playlist_root.songs.get_child_count() and real_index(calc_idx()) >= 0:
			emit_signal("panel_visible",true)
	else:
		if !ignore_mouse_input:
			emit_signal("panel_visible",false)


func block_song_highlighter(var x : bool) -> void:
	self.get_parent().get_parent().get_parent().set_process(x)
	self.set_process(x)
	self.set_process_input(x)
	emit_signal("panel_visible",x)


func toggle_processes(var x : bool) -> void:
	self.set_process(x)
	if !x:
		# releases the last focused song when leaving the ScrollContainer
		# songsspace moue filters have ALL to be set to ignore for this to work
		if !get_global_rect().has_point(get_global_mouse_position()):
			emit_signal("space_exited",curr_idx)
	call_deferred("emit_signal","toggle_process",x)


func calc_idx() -> int:
	# songspace height and VboxSeparation need to be exactly their value
	var x : int =  int( (song_slider.value + mouse_pos.y - self.rect_position.y) / (SONGSPACE_HEIGHT + VBOX_SEPARATION) )
	if (x >= playlist_root.songs.get_child_count()):
		return -1;
	return x;


func set_filter_status(var status : bool) -> void:
	is_filtering = status


func real_index(var visible_idx : int) -> int:
	# fixes the wrong index being handled when filters are applied
	# only runs the check if a filter is applied
	if is_filtering and visible_idx >= 0:
		var counting_visible : int = 0
		for n in get_child(0).get_children():
			if n.is_visible():
				counting_visible += 1
			if counting_visible - 1 == visible_idx:
				return n.get_index();
		return -1;
	else:
		return visible_idx;
