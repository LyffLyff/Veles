extends HBoxContainer
# handles the resizing of the window if borderless is enabled

enum {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	TOP_RIGHT,
	TOP_LEFT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
}

const MIN_WINDOW_SIZE : Vector2 = Vector2(945,300)

var current_handle : int = -1	#saves the index of the handle the users mouse is in, -1 -> none
var following : bool
var mouse_start_pos : Vector2
var new_window_size : Vector2 = Vector2.ZERO
var new_window_pos : Vector2 = OS.get_window_position()
var set_pos : bool = false

onready var handles : Array = [
	$TopBottom/CenterTop,
	$TopBottom/CenterBottom,
	$LeftHandles/LeftHandle,
	$RightHandles/RightHandle,
	$RightHandles/RightTop,
	$LeftHandles/LeftTop,
	$RightHandles/RightBottom,
	$LeftHandles/LeftBottom
]


func _ready():
	OS.set_min_window_size(MIN_WINDOW_SIZE)
	new_window_size = OS.get_window_size()
	for n in handles.size():
		if handles[n].connect("mouse_entered",self,"_on_handle_entered",[n]) != OK:
			Global.message("CONNECTING HANDLE TO MOUSE ENTERED WINDOW", Enumerations.MESSAGE_ERROR)
		if handles[n].connect("mouse_exited",self,"_on_handle_exited") != OK:
			Global.message("CONNECTING HANDLE TO MOUSE EXITED WINDOW", Enumerations.MESSAGE_ERROR)


func _enter_tree():
	# hiding of app is not in borderless mode
	self.set_visible( bool( ProjectSettings.get("display/window/size/borderless") ) )


func _process(_delta):
	if following:
		set_pos = false
		new_window_pos = OS.window_position
		resize_window()


func _on_handle_gui_input(var event) ->void:
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT:
			if !Global.window_maximized:
				mouse_start_pos = get_global_mouse_position()
				following = !following
				if following: 
					Global.emit_signal("window_resize_started")
				else: 
					Global.emit_signal("window_resize_ended")


func _on_handle_entered(var idx : int):
	current_handle = idx


func _on_handle_exited():
	if !following:
		current_handle = -1


func resize_window() -> void:
	match current_handle:
		
		TOP:
			expand_top()
		
		BOTTOM:
			expand_bottom()
		
		LEFT:
			expand_left()
		
		RIGHT:
			expand_right()
		
		TOP_RIGHT:
			expand_right()
			expand_top()
		
		TOP_LEFT:
			expand_left()
			expand_top()
		
		BOTTOM_RIGHT:
			expand_right()
			expand_bottom()
		
		BOTTOM_LEFT:
			expand_left()
			expand_bottom()
	
	# setting the updated window size and position
	# only updates position 
	if new_window_size.x > MIN_WINDOW_SIZE.x:
		OS.window_size.x = new_window_size.x
		if set_pos:
			OS.window_position.x = new_window_pos.x
	
	if new_window_size.y > MIN_WINDOW_SIZE.y:
		OS.window_size.y = new_window_size.y
		if set_pos:
			OS.window_position.y = new_window_pos.y


func expand_right() -> void:
	new_window_size.x = get_global_mouse_position().x


func expand_left() -> void:
	new_window_size.x = OS.window_size.x - get_global_mouse_position().x
	
	# setting both values even though only one changes
	# since the window could have been moved otherwise -> top window bar
	new_window_pos.x = OS.window_position.x + get_global_mouse_position().x
	set_pos = true


func expand_top() -> void:
	new_window_pos.y = OS.window_position.y + get_global_mouse_position().y
	new_window_size.y = -get_global_mouse_position().y + OS.window_size.y
	set_pos = true


func expand_bottom() -> void:
	new_window_size.y = get_global_mouse_position().y
