extends LineEdit

func set_text(var new_text : String) -> void:
	# override because normal set_text() does not emit text_entered signal
	# -> needed to set Setting
	self.text = new_text
	self.emit_signal("text_entered",new_text)
