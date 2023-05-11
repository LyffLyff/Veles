extends Node
# a global scene made for having a standardised system
# for modulating nodes, often times buttons, in different states


func init_modulation(var obj : Control, var connect_method : int = CONNECT_DEFERRED) -> void:
	var _err : int = -1
	
	if obj.is_connected("mouse_entered", self, "modulate_hover"):
		# object already connected to modulation
		return 
	
	obj.connect("mouse_entered", self, "modulate_hover", [obj])
	_err = obj.connect("mouse_exited", self, "modulate_normal", [obj])
	if obj.has_signal("button_down"):
		_err = obj.connect("button_down", self, "modulate_pressed", [obj])
		_err = obj.connect("button_up", self, "modulate_hover", [obj])


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
		Color("aaaaaa"),
		0.1
	)


func modulate_normal(var object : CanvasItem):
	var _ptw : PropertyTweener = get_tree().create_tween().tween_property(
		object,
		"self_modulate",
		Color("ffffff"),
		0.1
	)

