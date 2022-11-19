extends LineEdit

func set_rotary_edit( var new_value : float) -> void:
	self.set_text( str(new_value).pad_decimals(1) )
