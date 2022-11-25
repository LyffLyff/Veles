extends Label
# a label that can be instanced to show advanced Text/Info to the specific option the user hovers over

const HOVER_WAIT : float = 0.5

func init_context_label(var context : String) -> void:
	self.modulate.a = 0.0
	var _err = get_tree().create_timer(HOVER_WAIT, false).connect("timeout", self, "show_context", [context])


func show_context(var context : String) -> void:
	self.text = " " + context + " "
	self.rect_global_position = self.get_global_mouse_position() + Vector2(20, 0)
	var _ptw := create_tween().tween_property(
		self,
		"modulate:a",
		1.0,
		0.1
	)

