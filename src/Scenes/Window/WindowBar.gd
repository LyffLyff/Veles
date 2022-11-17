extends Control

signal window_changed
signal window_maximized

# the amount of space give to perform a maximize on the edges of the monitors
# the lower this value the more accurate the user has to be to maximize a window by crashing it on the edges
const MAXIMIZE_INACCURACY : int = 10

var maximized : bool = false
var half_maxed : bool = false
var last_position : Vector2 = Vector2.ZERO			# saves last position of window before going fullscreen
var last_size : Vector2 = Vector2.ZERO
var screen : int = 0 
var following = false
var dragging_start_position : Vector2 = Vector2.ZERO
var offset : Vector2 = Vector2.ZERO
var maximize_on_loss : bool = false
var half_maximize_on_loss : bool = false
var screen_side_idx : int = -1
var screen_sides : PoolRealArray = []

onready var buttons : Array = [$Options/Quit,$Options/Minimize,$Options/Maximise]


func _ready():
	
	# initialising color
	self.get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS,"WindowBarColor")
	)
	
	# setting up all the side Maximizing
	screen_sides.push_back(0)
	for n in OS.get_screen_count():
		var x : float = OS.get_screen_size(n).x + screen_sides[n]
		screen_sides.push_back(x)
		screen_sides.push_back(x)
	
	# connecting buttons
	for n in buttons.size():
		if buttons[n].connect("mouse_entered",Modulator,"modulate_hover",[buttons[n]]):
			Global.root.message("CONNECTING MOUSE ENTERED SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
		if buttons[n].connect("mouse_exited",Modulator,"modulate_normal",[buttons[n]]):
			Global.root.message("CONNECTING MOUSE EXITED SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)


func _enter_tree():
	# changing visibility of the window bar depending on if the app is borderless
	self.set_visible( bool( ProjectSettings.get("display/window/size/borderless") ) )


func _process(_delta):
	if following:
		OS.set_window_position(OS.window_position + get_global_mouse_position() + offset - dragging_start_position)
	else:
		if maximize_on_loss:
			maximize_on_loss = false
			_on_Maximise_pressed(0)
		if half_maximize_on_loss:
			half_maximize_on_loss = false
			_on_Maximise_pressed(1)


func _on_WindowBar_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			dragging_start_position = get_local_mouse_position()
			if offset.x > 0:
				# resets the offset if it was bigger than 0
				# to get normal behaviour when moving the window normally
				offset = Vector2.ZERO
			if maximized:
				# adding offset since the window will be far away from the mouse
				# when the window was maximized
				offset = get_global_mouse_position() / 2
				unmaximize()
			if half_maxed:
				# no need for the offset here
				unmaximize()
			following = !following
			
			# only checking for theoretical maximizing of the window when the MOUSE LEFT Button for following has been released
			if !following:
				# maximizing on the Sides of the Screen
				var horizontal_mouse_screen_pos : float = OS.window_position.x + get_global_mouse_position().x
				half_maximize_on_loss = false
				for n in screen_sides.size():
					# checking if the user mouse is in range of the monitor edges
					if horizontal_mouse_screen_pos < screen_sides[n] + MAXIMIZE_INACCURACY and horizontal_mouse_screen_pos > screen_sides[n] - MAXIMIZE_INACCURACY:
						
						# tells if the user has multiple Monitors they can half maximize in the middle on BOTH sides
						if horizontal_mouse_screen_pos < screen_sides[n] + MAXIMIZE_INACCURACY and horizontal_mouse_screen_pos > screen_sides[n]:
							screen_side_idx = n + 1
						else:
							screen_side_idx = n
						half_maximize_on_loss = true
						break;
				# maximizing on Top of the Screen
				# theoretically possible 
				if OS.window_position.y < 0 :
					maximize_on_loss = true
				else:
					maximize_on_loss = false


func _on_Minimize_pressed():
	OS.set_window_minimized(true)


func _on_Maximise_pressed(var type : int = 0):
	# made my own maximize function because the one in Godot is weird with borderless windows 
	# -> kills transparency, always fullscreen -> not maximized
	if !maximized and !half_maxed:
		emit_signal("window_maximized","visible",false)
		last_size = OS.get_window_size()
		last_position = OS.get_window_position()
		screen = OS.get_current_screen()
		match type:
			0:
				maximized = true
				var screen_addition : float = 0
				match screen:
					0:																						#ONE MONITOR
						screen_addition = 0
						OS.set_window_position(Vector2(screen_addition, 0))
						#OS.set_window_size(Vector2(OS.get_screen_size().x * 1.001,OS.get_screen_size().y * 0.97))
						OS.set_window_size(Vector2(OS.get_screen_size().x + 0,OS.get_screen_size().y - 40))
					1:																						#TWO MONITORS
						screen_addition = OS.get_screen_size(0).x
						OS.set_window_position(Vector2(screen_addition, 0))
						#OS.set_window_size(Vector2(OS.get_screen_size().x * 1.001,OS.get_screen_size().y * 0.97))
						OS.set_window_size(Vector2(OS.get_screen_size().x + 0,OS.get_screen_size().y - 40))
					2:																						#THREE MONITORS
						screen_addition = OS.get_screen_size(1).x + OS.get_screen_size(0).y
						OS.set_window_position(Vector2(screen_addition, 0))
						#OS.set_window_size(Vector2(OS.get_screen_size().x * 1.001,OS.get_screen_size().y * 0.97))
						OS.set_window_size(Vector2(OS.get_screen_size().x + 0,OS.get_screen_size().y - 40))
			1:
				half_maxed = true
				if screen_side_idx % 2 != 0:
					#if on the right side of a monitor
					#screen_sides[screen_side_idx / 2] / 2
					OS.window_position = Vector2(screen_sides[screen_side_idx] - (OS.get_screen_size(screen_side_idx / 2).x / 2),0)
				else:
					#if on the left side of a monitor
					OS.window_position = Vector2(screen_sides[screen_side_idx],0)
				OS.window_size = Vector2(OS.get_screen_size().x/2,OS.get_screen_size().y - 40)
		emit_signal("window_changed")
		Global.window_changed(true)
			
	else:
		unmaximize()


func _on_Quit_pressed():
	get_tree().quit()


func unmaximize()-> void:
	emit_signal("window_maximized","visible",true)
	half_maxed = false
	maximized = false
	OS.set_window_size(last_size)
	OS.set_window_position(last_position)
	Global.window_changed(false)
