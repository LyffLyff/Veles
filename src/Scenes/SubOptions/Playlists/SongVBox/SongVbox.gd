#Extended Scroll Container
#Adds in a better way to detect the mouse while scrolling
#Adds in a "weighed Scroll" meaning it has acceleration and decceleration 
extends ScrollContainer


#SIGNALS
signal toggle_process
signal space_pressed
signal space_rightclick
signal space_entered
signal space_exited
signal PanelVisible
signal SpeedThresholdExceeded
signal SpeedThresholdSubceeded
signal decelerated

#CONSTANTS
const VBOX_SEPARATION : int = 3
const SONGSPACE_HEIGHT : int = 41
const NORMAL_BIAS : int = 5
const SCDROLLBAR_BIAS : int = 80
const FAST_SCROLL_THRESHOLD : float = 10.0

#NODES
onready var SongSlider : VScrollBar = get_v_scrollbar()
onready var Songs : VBoxContainer = get_child(2)

#VARIABLES
var idx : int = -1
var curr_idx : int = -1
var MAX_SCROLL_SPEED : float = 50.0
var MIN_SCROLL_SPEED : float = 0.0
var ACCELERARION : float = 2.5
var DECCELERATION : float = 0.25
var CurrentScrollSpeed : float = 0.0
var Accelerating : bool = false
var DecelerationWaiter : Timer = Timer.new()
var IgnoreMouseInput : bool = true
var MousePos : Vector2
#Filter Correction
var filter : bool = false
var IsFast : bool = false


#connects to each songspace and toggle its process to detect the mouse
#disable all processes when leaving this ScrollContainer to prevent misinput
func _ready():
	#Disabling Smooth scroll for a while
	IgnoreMouseInput = false
	self.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	
	#Ready
	self.add_child(DecelerationWaiter)
	DecelerationWaiter.wait_time = 0.5
	
	#V-Scrollbar
	SongSlider.set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	SongSlider.set_h_size_flags(SIZE_SHRINK_CENTER)
	SongSlider._ready()
	if SongSlider.connect("ScrollBarReleased", self, "BlockSongHighLighter",[true]):
		Global.root.message("Cannot Connect ScrollBarReleased to BlockSongHighLighter function",  SaveData.MESSAGE_ERROR )
	if SongSlider.connect("ScrollBarPressed", self, "BlockSongHighLighter",[false]):
		Global.root.message("Cannot Connect ScrollBarPressed to BlockSongHighLighter function",  SaveData.MESSAGE_ERROR )
	if SongSlider.connect("mouse_entered",SongSlider,"grab_click_focus"):
		Global.root.message("CONNECTING SONG SCROLLBAR TO VScrollbarFocusser FUNCTION",  SaveData.MESSAGE_ERROR )
	if SongSlider.connect("mouse_entered",self,"emit_signal",["space_exited",curr_idx]):
		Global.root.message("CONNECTING SONG SCROLLBAR TO VScrollbarFocusser FUNCTION",  SaveData.MESSAGE_ERROR )
	
	#ProcessToggler
	if self.connect("PanelVisible",self.get_parent().get_parent().get_parent().get_parent().get_node("SongHighlighter"),"set_visible"):
		Global.root.message("CONNECTING TOGGLE PROCESS TO SONGSCROLLER VISIBILITY",  SaveData.MESSAGE_ERROR )


func _notification(what):
	#Disabling Processes when focus on the wondpw has been lost
	if what == MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
		#Exiting the Current Space, so it won't be falsely focused
		emit_signal("space_exited",curr_idx)
		#self.toggle_processes(false)
	elif what == MainLoop.NOTIFICATION_WM_MOUSE_ENTER:
		pass
		#self.toggle_processes(true)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		#self.set_process_input(false)
		MousePos = Vector2.ZERO
		self.CurrentScrollSpeed = 0.0
		call_deferred("emit_signal","decelerated")
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		pass
		#self.set_process_input(true)


func _input(var event):
	if event is InputEventMouseMotion:
		MousePos = event.global_position
	elif event is InputEventMouseButton:
		if IgnoreMouseInput:
			return;
		if event.is_pressed():
			idx = calc_idx()
			#if !Input.is_key_pressed(KEY_SHIFT):
			if event.button_index == BUTTON_WHEEL_DOWN:
				AccelerateScroll(+1)
				Accelerating = true
			elif event.button_index == BUTTON_WHEEL_UP:
				AccelerateScroll(-1)
				Accelerating = true
			elif event.button_index == BUTTON_LEFT:
				if idx >= 0:
						#Checking if inside  of Rect of Songs 
						if get_parent().get_global_rect().has_point(MousePos):
							#Preventing a click if its just next  to the Scrollbar
							if get_global_rect().position.x + get_global_rect().size.x >= MousePos.x + 25:
								if (Global.PlaylistPressed < -2 and Global.PlaylistPressed != SongLists.CurrentPlayList) or Global.PlaylistPressed == -2:
									SongLists.CurrentTempSmartPlaylist = SongLists.PressedTempSmartPlaylist
								call_deferred("emit_signal","space_pressed",RealIndex(idx))
			elif event.button_index == BUTTON_RIGHT:
				if self.get_global_rect().has_point( get_global_mouse_position() ) and idx >= 0:
					call_deferred("emit_signal","space_rightclick",RealIndex(idx))


func _physics_process(_delta):
	#if the VBox and the ScrollContainer have this point
	if get_child(0).get_global_rect().has_point( MousePos ) and self.get_global_rect().has_point( MousePos ) and MousePos.x  + 40 < get_global_rect().size.x + get_global_rect().position.x:
		if Songs.get_child_count() > 0 and RealIndex( calc_idx() ) < Songs.get_child_count() and RealIndex( calc_idx() ) >= 0:
			emit_signal("PanelVisible",true)
	else:
		if !IgnoreMouseInput:
			emit_signal("PanelVisible",false)
	
	return
	#Weighed Scroll Container
	if CurrentScrollSpeed != 0.0:
		if abs(CurrentScrollSpeed) > MIN_SCROLL_SPEED:
			SongSlider.value += CurrentScrollSpeed
		else:
			CurrentScrollSpeed = 0.0
		#the vertical size needs to be subtracted for the MAX VALUE of the Scrollbar to be real
		if SongSlider.value == (SongSlider.max_value - self.rect_size.y) or SongSlider.value == 0.0:
			call_deferred("emit_signal","decelerated")
			CurrentScrollSpeed = 0.0
		if CurrentScrollSpeed >= MAX_SCROLL_SPEED:
			CurrentScrollSpeed = MAX_SCROLL_SPEED
	if !Accelerating:
		if CurrentScrollSpeed < 0.0:
			CurrentScrollSpeed += DECCELERATION 
		elif CurrentScrollSpeed > 0.0:
			CurrentScrollSpeed -= DECCELERATION 
		else:
			call_deferred("emit_signal","decelerated")
	Accelerating = false

	#Smoothing the Scroll by emitting signals on certain speed threshold
	if !IsFast and abs(CurrentScrollSpeed) > FAST_SCROLL_THRESHOLD:
		IsFast = true
		emit_signal("SpeedThresholdExceeded")
	elif IsFast and abs(CurrentScrollSpeed) < FAST_SCROLL_THRESHOLD:
		IsFast = false
		emit_signal("SpeedThresholdSubceeded")


func BlockSongHighLighter(var x : bool) -> void:
	self.get_parent().get_parent().get_parent().set_process(x)
	self.set_process(x)
	self.set_process_input(x)
	emit_signal("PanelVisible",x)


func toggle_processes(var x : bool) -> void:
	if CurrentScrollSpeed > 0:
		#If the Scroll Container is currently decelerating it
		#waits for the Currentspeed to reach 0 before allowing the pricess to be disabled
		#this prevents the ScrollContainer to halt while in the middle of decelerating
		yield(self,"decelerated")
	self.set_process(x)
	if !x:
		#releases the last focused song when leaving the ScrollContainer
		#songsspace moue filters have ALL to be set to ignore for this to work
		if !get_global_rect().has_point(get_global_mouse_position()):
			emit_signal("space_exited",curr_idx)
	call_deferred("emit_signal","toggle_process",x)


func calc_idx() -> int:
	#Songspace Height and VboxSeparation need to be EXACTLY this value
	var x : int =  int( (SongSlider.value + MousePos.y - self.rect_global_position.y) / (SONGSPACE_HEIGHT + VBOX_SEPARATION) )
	if (x >= Songs.get_child_count()):
		return -1;
	return x;


func SetFilterStatus(var status : bool) -> void:
	filter = status


#fixes the wrong index being handled when filters are applied
func RealIndex(var visible_idx : int) -> int:
	#only runs the check if a filter is applied
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


func AccelerateScroll(var ScrollDirection : int) -> void:
	if abs(CurrentScrollSpeed) < MAX_SCROLL_SPEED:
		CurrentScrollSpeed += ACCELERARION * ScrollDirection
	
