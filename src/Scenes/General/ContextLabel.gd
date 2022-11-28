extends Label
# a label that can be instanced to show advanced Text/Info to the specific option the user hovers over

const HOVER_WAIT : float = 0.5

func init_context_label(var context : String) -> void:
	self.modulate.a = 0.0
	var _err = get_tree().create_timer(HOVER_WAIT, false).connect("timeout", self, "show_context", [context])


func show_context(var context : String) -> void:
	self.text = " " + context + " "
	set_context_pos()
	var _ptw := create_tween().tween_property(
		self,
		"modulate:a",
		1.0,
		0.1
	)


func set_context_pos() -> void:
	self.rect_global_position = self.get_global_mouse_position() + Vector2(20, -20)
	if self.rect_global_position.x  + 150 > OS.get_window_size().x:
		self.rect_global_position.x -= 150
	if self.rect_global_position.y  + 100 > OS.get_window_size().y:
		self.rect_global_position.y -= 100
