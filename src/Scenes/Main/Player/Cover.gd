extends TextureButton

#VARIABLES
var _err : bool
var panel_tw : Tween = Tween.new()
var pointer_tw : Tween = Tween.new()
onready var HoverPanel : Panel = get_child(0)
onready var Pointer : TextureRect = get_child(0).get_child(0)


func _ready():
	self.add_child(panel_tw)
	self.add_child(pointer_tw)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
		#Mouse is not being updated when exiting window, so the tween won't be reversed when exiting sometimes
		TweenHoverPanel(false)
		self.set_process(false)


func _process(var _delta : float):
	if !self.get_global_rect().has_point( self.get_global_mouse_position() ):
		TweenHoverPanel(false)
		self.set_process(false)


func _on_Cover_mouse_entered():
	self.set_process(true)
	TweenHoverPanel(true)


func TweenHoverPanel(var toggle : bool) -> void:
		var initial_val : float = HoverPanel.modulate.a
		
		SetPointerRotation()
		
		if panel_tw.is_connected("tween_all_completed",HoverPanel,"set_visible"):
			panel_tw.disconnect("tween_all_completed",HoverPanel,"set_visible")
		if panel_tw.is_active():
			_err = panel_tw.remove_all()
		
		if toggle:
			HoverPanel.set_visible(true)
			_err = panel_tw.interpolate_property ( HoverPanel, "modulate:a", initial_val, 1.0, 0.3, Tween.TRANS_QUAD)
			_err = panel_tw.start()
		else:
			_err = panel_tw.interpolate_property ( HoverPanel, "modulate:a", initial_val, 0.0, 0.3, Tween.TRANS_QUAD)
			_err = panel_tw.start()
			_err = panel_tw.connect("tween_all_completed",HoverPanel,"set_visible",[false])


func SetPointerRotation() -> void:
	if SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "ImageViewActivated") == true:
		Pointer.set_rotation_degrees(180.0)
	else:
		Pointer.set_rotation_degrees(0.0)


func OnCoverPressed():
	#Rotating the Pointer either up or down -> depending on if Image View is activated or not
	
	var final_rotation : float = float( SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "ImageViewActivated") ) * 180.0
	
	if !Pointer.is_visible():
		return
	if pointer_tw.is_active():
		_err = pointer_tw.remove_all()
	
	_err = pointer_tw.interpolate_property(
		Pointer,
		"rect_rotation",
		Pointer.get_rotation_degrees(),
		final_rotation,
		0.3,
		Tween.TRANS_CUBIC
	)
	_err = pointer_tw.start()
