extends LineEdit


func SetRotaryEdit( var NewValue : float) -> void:
	self.set_text( str(NewValue).pad_decimals(1) )
