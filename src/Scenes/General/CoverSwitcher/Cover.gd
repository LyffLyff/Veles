extends TextureRect

onready var panel : PanelContainer = $PanelContainer

func _ready():
	panel.material.set("shader_param/strength", 0.0)


func _on_Cover_mouse_entered():
	var _ptw = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).tween_property(
		panel.material,
		"shader_param/strength",
		0.5,
		0.15
	)


func _on_Cover_mouse_exited():
	var _ptw = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).tween_property(
		panel.material,
		"shader_param/strength",
		0.0,
		0.15
	)

