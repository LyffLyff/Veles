extends LineEdit


func set_text(var NewText : String) -> void:
	#Override because normal set_text() does not emit text_entered signal
	#-> needed to set Setting
	self.text = NewText
	self.emit_signal("text_entered",NewText)
