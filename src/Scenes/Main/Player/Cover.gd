extends TextureButton
# the script for the small version of the current songs cover in the left side of the player

const TW_DURATION : float = 0.4

var _err : bool
var is_pointer_tweening : bool = false

onready var hover_panel : PanelContainer = get_child(0)
onready var pointer : TextureRect = get_child(0).get_child(0)

func _ready():
	# init hover panel
	var clr : Color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "PlayerBackground")
	clr.a = 0.5
	hover_panel.material.set_shader_param("color", clr)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
		# mouse is not being updated when exiting window, so the tween won't be reversed when exiting sometimes
		self.set_process(false)
		tween_hover_panel(false)


func _process(var _delta : float):
	if !self.get_global_rect().has_point(self.get_global_mouse_position()):
		self.set_process(false)
		tween_hover_panel(false)


func _on_Cover_mouse_entered():
	self.set_process(true)
	tween_hover_panel(true)


func _on_Cover_pressed():
	# rotating the Pointer either up or down -> depending on if Image View is activated or not
	if is_pointer_tweening:
		set_pointer_rotation()
		return
	var final_rotation : float = float( SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewActivated") ) * 180.0
	is_pointer_tweening = true
	var ptw : PropertyTweener = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).tween_property(
		pointer,
		"rect_rotation",
		final_rotation,
		TW_DURATION
	)
	_err = ptw.connect("finished",self,"set", ["is_pointer_tweening", false])


func tween_hover_panel(var toggle : bool) -> void:
		var initial_val : float = hover_panel.modulate.a
		var final_val : float = float(toggle)
		set_pointer_rotation()
		
		var _ptw : PropertyTweener = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).tween_property(
			hover_panel,
			"modulate:a",
			final_val,
			TW_DURATION
		)


func set_pointer_rotation() -> void:
	pointer.rect_rotation = float(SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewActivated")) * 180.0
