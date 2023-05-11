extends Button

signal right_clicked

const EXPAND_MARGIN : int = 4

onready var username : Label = $VBoxContainer/Username
onready var profile_img : TextureRect = $VBoxContainer/ProfileImage
onready var bg_panel : StyleBox = $Panel.get_stylebox("panel")


func _on_UserProfileContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_RIGHT:
				emit_signal("right_clicked")


func _on_UserProfileContainer_mouse_entered():
	var tw = create_tween().set_trans(Tween.TRANS_QUART)
	var _ptw : PropertyTweener = tw.tween_property(bg_panel, "expand_margin_left", EXPAND_MARGIN, 0.1)
	_ptw = tw.parallel().tween_property(bg_panel, "expand_margin_right", EXPAND_MARGIN, 0.1)
	_ptw = tw.parallel().tween_property(bg_panel, "expand_margin_bottom", EXPAND_MARGIN, 0.1)
	_ptw = tw.parallel().tween_property(bg_panel, "expand_margin_top", EXPAND_MARGIN, 0.1)


func _on_UserProfileContainer_mouse_exited():
	var tw = create_tween().set_trans(Tween.TRANS_QUART)
	tw.tween_property(bg_panel, "expand_margin_left", 0, 0.1)
	tw.parallel().tween_property(bg_panel, "expand_margin_right", 0, 0.1)
	tw.parallel().tween_property(bg_panel, "expand_margin_bottom", 0, 0.1)
	tw.parallel().tween_property(bg_panel, "expand_margin_top", 0, 0.1)
