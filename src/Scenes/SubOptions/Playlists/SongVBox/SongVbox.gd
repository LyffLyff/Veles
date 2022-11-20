extends ScrollContainer
# extended Scroll Container
# adds in a better way to detect the mouse while scrolling
# adds in a "weighed Scroll" meaning it has acceleration and decceleration 

signal toggle_process
signal space_pressed
signal space_rightclick
signal space_entered
signal space_exited
signal PanelVisible
signal speed_threshold_exceeded
signal speed_threshold_subceeded
signal decelerated

const VBOX_SEPARATION : int = 3
const SONGSPACE_HEIGHT : int = 41
const NORMAL_BIAS : int = 5
const FAST_SCROLL_THRESHOLD : float = 10.0
const MAX_SCROLL_SPEED : float = 50.0
const MIN_SCROLL_SPEED : float = 0.0
const ACCELERARION : float = 2.5
const DECCELERATION : float = 0.25

var idx : int = -1
var curr_idx : int = -1
var current_scroll_speed : float = 0.0
var is_accelerating : bool = false
var ignore_mouse_input : bool = true
var mouse_pos : Vector2
var filter : bool = false
var is_fast : bool = false

onready var song_slider : VScrollBar = get_v_scrollbar()
onready var songs : VBoxContainer = get_child(2)

# connects to each songspace and toggle its process to detect the mouse
# disable all processes when leaving this ScrollContainer to prevent misinput
func _ready():
	# disabling Smooth scroll for a while
	ignore_mouse_input = false
	self.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	
	# V-Scrollbar
	song_slider.set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
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
	if self.connect("PanelVisible",self.get_parent().get_parent().get_parent().get_parent().get_node("SongHighlighter"),"set_visible"):
		Global.root.message("CONNECTING TOGGLE PROCESS TO SONGSCROLLER VISIBILITY",  SaveData.MESSAGE_ERROR )


func _notification(what):
	# disabling Processes when focus on the wondpw has been lost
	if what == MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
		# exiting the Current Space, so it won't be falsely focused
		emit_signal("space_exited",curr_idx)
		#self.toggle_processes(false)
	elif what == MainLoop.NOTIFICATION_WM_MOUSE_ENTER:
		pass
		#self.toggle_processes(true)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		#self.set_process_input(false)
		mouse_pos = Vector2.ZERO
		self.current_scroll_speed = 0.0
		call_deferred("emit_signal","decelerated")
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		pass
		#self.set_process_input(true)


func _input(var event):
	if event is InputEventMouseMotion:
		mouse_pos = event.global_position
	elif event is InputEventMouseButton:
		if ignore_mouse_input:
			return;
		if event.is_pressed():
			idx = calc_idx()
			if event.button_index == BUTTON_WHEEL_DOWN:
				accelerate_scroll(+1)
				is_accelerating = true
			elif event.button_index == BUTTON_WHEEL_UP:
				accelerate_scroll(-1)
				is_accelerating = true
			elif event.button_index == BUTTON_LEFT:
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
					call_deferred("emit_signal","space_rightclick",real_index(idx))


func _physics_process(_delta):
	# if the VBox and the ScrollContainer have this point
	if get_child(0).get_global_rect().has_point(mouse_pos) and self.get_global_rect().has_point(mouse_pos) and mouse_pos.x  + 40 < get_global_rect().size.x + get_global_rect().position.x:
		if songs.get_child_count() > 0 and real_index(calc_idx()) < songs.get_child_count() and real_index(calc_idx()) >= 0:
			emit_signal("PanelVisible",true)
	else:
		if !ignore_mouse_input:
			emit_signal("PanelVisible",false)
	
	return
	# weighed Scroll Container
	if current_scroll_speed != 0.0:
		if abs(current_scroll_speed) > MIN_SCROLL_SPEED:
			song_slider.value += current_scroll_speed
		else:
			current_scroll_speed = 0.0
		# the vertical size needs to be subtracted for the MAX VALUE of the Scrollbar to be real
		if song_slider.value == (song_slider.max_value - self.rect_size.y) or song_slider.value == 0.0:
			call_deferred("emit_signal","decelerated")
			current_scroll_speed = 0.0
		if current_scroll_speed >= MAX_SCROLL_SPEED:
			current_scroll_speed = MAX_SCROLL_SPEED
	if !is_accelerating:
		if current_scroll_speed < 0.0:
			current_scroll_speed += DECCELERATION 
		elif current_scroll_speed > 0.0:
			current_scroll_speed -= DECCELERATION 
		else:
			call_deferred("emit_signal","decelerated")
	is_accelerating = false

	# smoothing the Scroll by emitting signals on certain speed threshold
	if !is_fast and abs(current_scroll_speed) > FAST_SCROLL_THRESHOLD:
		is_fast = true
		emit_signal("speed_threshold_exceeded")
	elif is_fast and abs(current_scroll_speed) < FAST_SCROLL_THRESHOLD:
		is_fast = false
		emit_signal("speed_threshold_subceeded")


func block_song_highlighter(var x : bool) -> void:
	self.get_parent().get_parent().get_parent().set_process(x)
	self.set_process(x)
	self.set_process_input(x)
	emit_signal("PanelVisible",x)


func toggle_processes(var x : bool) -> void:
	if current_scroll_speed > 0:
		# If the Scroll Container is currently decelerating it
		# waits for the Currentspeed to reach 0 before allowing the pricess to be disabled
		# this prevents the ScrollContainer to halt while in the middle of decelerating
		yield(self,"decelerated")
	self.set_process(x)
	if !x:
		# releases the last focused song when leaving the ScrollContainer
		# songsspace moue filters have ALL to be set to ignore for this to work
		if !get_global_rect().has_point(get_global_mouse_position()):
			emit_signal("space_exited",curr_idx)
	call_deferred("emit_signal","toggle_process",x)


func calc_idx() -> int:
	# songspace height and VboxSeparation need to be exactly their value
	var x : int =  int( (song_slider.value + mouse_pos.y - self.rect_global_position.y) / (SONGSPACE_HEIGHT + VBOX_SEPARATION) )
	if (x >= songs.get_child_count()):
		return -1;
	return x;


func set_filter_status(var status : bool) -> void:
	filter = status


func real_index(var visible_idx : int) -> int:
	# fixes the wrong index being handled when filters are applied
	# only runs the check if a filter is applied
	if filter and visible_idx >= 0:
		var counting_visible : int = 0
		for n in get_child(0).get_children():
			if n.is_visible():
				counting_visible += 1
			if counting_visible - 1 == visible_idx:
				return n.get_index();
		return -1;
	else:
		return visible_idx;


func accelerate_scroll(var direction : int) -> void:
	if abs(current_scroll_speed) < MAX_SCROLL_SPEED:
		current_scroll_speed += ACCELERARION * direction
