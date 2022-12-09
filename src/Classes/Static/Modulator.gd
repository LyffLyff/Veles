extends Node


func modulate_hover(var object : CanvasItem) -> void:
	var _ptw : PropertyTweener = get_tree().create_tween().tween_property(
		object,
		"self_modulate",
		Color("cccccc"),
		0.1
	)

func modulate_pressed(var object : CanvasItem):
	var _ptw : PropertyTweener = get_tree().create_tween().tween_property(
		object,
		"self_modulate",
		Color("bbbbbb"),
		0.1
	)


func modulate_normal(var object : CanvasItem):
	var _ptw : PropertyTweener = get_tree().create_tween().tween_property(
		object,
		"self_modulate",
		Color("ffffff"),
		0.1
	)

