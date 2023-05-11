extends VBoxContainer

signal toggle_process
signal space_pressed
signal space_rightclicked
signal space_entered
signal space_exited
signal panel_visible

const VBOX_SEPARATION : int = 3
const SONGSPACE_HEIGHT : int = 41

var idx : int = -1
var is_filtering : bool = false
var playlist_root_rect : Rect2 = Rect2()
var mouse_exited_window : bool = false

onready var playlist_root : Control = null

# connects to each songspace and toggle its process to detect the mouse
# disable all processes when leaving this ScrollContainer to prevent misinput
func init_song_scroller():
	self.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	
	if self.connect("panel_visible", playlist_root, "set_highlighter_visibility", []):
		Global.message("CONNECTING TOGGLE PROCESS TO SONGSCROLLER VISIBILITY",  Enumerations.MESSAGE_ERROR )


func _input(var event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				idx = calc_idx()
				if idx >= 0:
						# checking if inside  of Rect of Songs
						# and if the mouse is not on the songlist header
						if playlist_root_rect.has_point(get_global_mouse_position()) and get_global_mouse_position().y > self.get_global_position().y:
							# preventing a click if its just next to the Scrollbar
							if !self.get_global_rect().position.x + get_global_rect().size.x >= get_global_mouse_position().x + 25:
								return
							if Global.pressed_playlist_idx <= -2:
								SongLists.current_temporary_playlist = SongLists.pressed_temporary_playlist
							call_deferred("emit_signal", "space_pressed", real_index(idx))
			elif event.button_index == BUTTON_RIGHT:
				idx = calc_idx()
				if playlist_root_rect.has_point(get_global_mouse_position()) and idx >= 0:
					var r_idx : int = real_index(idx)
					if r_idx >= 0:
						self.emit_signal("panel_visible", false)
						call_deferred("emit_signal", "space_rightclicked", r_idx)


func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_exited_window = true
		self.emit_signal("panel_visible", false)
	elif what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_exited_window = false


func _process(var _delta : float):
	# if the Vbox and the ScrollContainer have this point
	if playlist_root_rect.has_point(get_global_mouse_position()) and self.get_global_rect().has_point(get_global_mouse_position()) and !mouse_exited_window:
		if playlist_root.song_vbox.get_child_count() > 0 and self.calc_idx() < playlist_root.song_vbox.get_child_count() and self.calc_idx() >= 0:
			playlist_root.set_highlighter_visibility(true)
			return
	playlist_root.set_highlighter_visibility(false)


func set_filter_status(var status : bool) -> void:
	is_filtering = status


func calc_idx() -> int:
	# songspace height and VboxSeparation need to be exactly their value
	var x : int =  int((self.get_global_mouse_position().y - self.rect_global_position.y) / (SONGSPACE_HEIGHT + VBOX_SEPARATION) )
	if x >= playlist_root.song_vbox.get_child_count():
		return -1;
	return x;


func real_index(var visible_idx : int) -> int:
	# fixes the wrong index being handled when filters are applied
	# only runs the check if a filter is applied
	if is_filtering and visible_idx >= 0:
		var counting_visible : int = 0
		for n in self.get_children():
			if n.is_visible():
				counting_visible += 1
			if counting_visible - 1 == visible_idx:
				return n.get_index();
		return -1;
	else:
		return visible_idx;

