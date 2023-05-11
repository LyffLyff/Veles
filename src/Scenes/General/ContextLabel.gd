extends Label
# a label that can be instanced to show advanced Text/Info to the specific option the user hovers over

const HOVER_WAIT : float = 1.0

func init_context_label(var context : String) -> void:
	self.modulate.a = 0.0
	var _err = get_tree().create_timer(HOVER_WAIT, false).connect("timeout", self, "show_context", [context])


func show_context(var context : String) -> void:
	self.text = context
	self.call_deferred("set_context_pos")	# deferred -> so rect_size has been updated with text
	var _ptw := create_tween().tween_property(
		self,
		"modulate:a",
		1.0,
		0.1
	)


func set_context_pos() -> void:
	self.rect_global_position = self.get_global_mouse_position() + Vector2(20, -20)
	if self.get_global_mouse_position().x  + self.rect_size.x + 30 > OS.get_window_size().x:
		self.rect_global_position.x -= (self.rect_size.x + 30)
	if self.get_global_mouse_position().y + self.rect_size.y + 30 > OS.get_window_size().y:
		self.rect_global_position.y -= (self.rect_size.y + 10)
