extends HBoxContainer

#WINDOW RESIZER

#ENUMS
enum {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	TOP_RIGHT,
	TOP_LEFT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT
}

#NODES
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

#CONSTANTS
const MIN_WINDOW_SIZE : Vector2 = Vector2(945,300)


#VARIABLES
#saves the index of the handle the users mouse is in
#if it's in none its -1
var current_handle : int = -1
var following : bool
var mouse_start_pos : Vector2
var NewWindowSize : Vector2 = Vector2.ZERO
var NewWindowPos : Vector2 = OS.get_window_position()
var set_pos : bool = false


func _enter_tree():
	self.set_visible( bool( ProjectSettings.get("display/window/size/borderless") ) )


func _ready():
	OS.set_min_window_size(MIN_WINDOW_SIZE)
	NewWindowSize = OS.get_window_size()
	for n in handles.size():
		if handles[n].connect("mouse_entered",self,"_on_handle_entered",[n]) != OK:
			Global.root.Message("CONNECTING HANDLE TO MOUSE ENTERED WINDOW", SaveData.MESSAGE_ERROR)
		if handles[n].connect("mouse_exited",self,"_on_handle_exited") != OK:
			Global.root.Message("CONNECTING HANDLE TO MOUSE EXITED WINDOW", SaveData.MESSAGE_ERROR)


func _on_handle_entered(var idx : int):
	current_handle = idx


func _on_handle_exited():
	if !following:
		current_handle = -1


func _on_handle_gui_input(var event) ->void:
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT:
			if !Global.WindowMaximized:
				mouse_start_pos = get_global_mouse_position()
				following = !following


func _process(_delta):
	if following:
		set_pos = false
		NewWindowPos = OS.window_position
		resize_window()


func resize_window() -> void:
	match current_handle:
		
		TOP:
			ExpandTop()
		
		BOTTOM:
			ExpandBottom()
		
		LEFT:
			ExpandLeft()
		
		RIGHT:
			ExpandRight()
		
		TOP_RIGHT:
			ExpandRight()
			ExpandTop()
		
		TOP_LEFT:
			ExpandLeft()
			ExpandTop()
		
		BOTTOM_RIGHT:
			ExpandRight()
			ExpandBottom()
		
		BOTTOM_LEFT:
			ExpandLeft()
			ExpandBottom()
	
	#Setting the updated window size and position
	#Only updates position 
	if NewWindowSize.x > MIN_WINDOW_SIZE.x:
		OS.window_size.x = NewWindowSize.x
		if set_pos:
			OS.window_position.x = NewWindowPos.x
	
	if NewWindowSize.y > MIN_WINDOW_SIZE.y:
		OS.window_size.y = NewWindowSize.y
		if set_pos:
			OS.window_position.y = NewWindowPos.y


func ExpandRight() -> void:
	NewWindowSize.x = get_global_mouse_position().x

func ExpandLeft() -> void:
	NewWindowSize.x = OS.window_size.x - get_global_mouse_position().x
	
	#Setting both values even though only one changes
	#since the window could have been moved otherwise -> top window bar
	NewWindowPos.x = OS.window_position.x + get_global_mouse_position().x
	set_pos = true

func ExpandTop() -> void:
	NewWindowPos.y = OS.window_position.y + get_global_mouse_position().y
	NewWindowSize.y = -get_global_mouse_position().y + OS.window_size.y
	set_pos = true

func ExpandBottom() -> void:
	NewWindowSize.y = get_global_mouse_position().y
