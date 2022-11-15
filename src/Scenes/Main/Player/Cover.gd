extends TextureButton
# the script for the small version of the current songs cover in the left side of the player

var _err : bool
var panel_tw : Tween = Tween.new()
var pointer_tw : Tween = Tween.new()

onready var hover_panel : Panel = get_child(0)
onready var pointer : TextureRect = get_child(0).get_child(0)


func _ready():
	self.add_child(panel_tw)
	self.add_child(pointer_tw)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
		#Mouse is not being updated when exiting window, so the tween won't be reversed when exiting sometimes
		tween_hover_panel(false)
		self.set_process(false)


func _process(var _delta : float):
	if !self.get_global_rect().has_point( self.get_global_mouse_position() ):
		tween_hover_panel(false)
		self.set_process(false)


func _on_Cover_mouse_entered():
	self.set_process(true)
	tween_hover_panel(true)


func _on_Cover_pressed():
	# rotating the Pointer either up or down -> depending on if Image View is activated or not
	
	var final_rotation : float = float( SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewActivated") ) * 180.0
	
	if !pointer.is_visible():
		return
	if pointer_tw.is_active():
		_err = pointer_tw.remove_all()
	
	_err = pointer_tw.interpolate_property(
		pointer,
		"rect_rotation",
		pointer.get_rotation_degrees(),
		final_rotation,
		0.3,
		Tween.TRANS_CUBIC
	)
	_err = pointer_tw.start()


func tween_hover_panel(var toggle : bool) -> void:
		var initial_val : float = hover_panel.modulate.a
		
		set_pointer_rotation()
		
		if panel_tw.is_connected("tween_all_completed",hover_panel,"set_visible"):
			panel_tw.disconnect("tween_all_completed",hover_panel,"set_visible")
		if panel_tw.is_active():
			_err = panel_tw.remove_all()
		
		if toggle:
			hover_panel.set_visible(true)
			_err = panel_tw.interpolate_property ( hover_panel, "modulate:a", initial_val, 1.0, 0.3, Tween.TRANS_QUAD)
			_err = panel_tw.start()
		else:
			_err = panel_tw.interpolate_property ( hover_panel, "modulate:a", initial_val, 0.0, 0.3, Tween.TRANS_QUAD)
			_err = panel_tw.start()
			_err = panel_tw.connect("tween_all_completed",hover_panel,"set_visible",[false])


func set_pointer_rotation() -> void:
	if SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewActivated") == true:
		pointer.set_rotation_degrees(180.0)
	else:
		pointer.set_rotation_degrees(0.0)
