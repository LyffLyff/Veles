extends Reference

class_name Modulator


static func modulate_hover(var object : CanvasItem) -> void:
	object.self_modulate = Color("cccccc")


static func modulate_pressed(var object : CanvasItem):
	object.self_modulate = Color("bbbbbb")


static func modulate_normal(var object : CanvasItem):
	object.self_modulate = Color("ffffff")

