extends MarginContainer


#NODES
onready var VerseText : TextEdit = $HBoxContainer/VerseText


#SIGNALS
signal VerseRectChanged
signal VerseTextChanged


func OnVerseTextChanged():
	emit_signal("VerseTextChanged")
	VerseText.rect_min_size.y = VerseText.get_line_count() * VerseText.get_line_height()


func _on_VerseContainer_item_rect_changed():
	emit_signal( "VerseRectChanged",self.get_index(), self.rect_size.y )


func OnUpPressed():
	self.get_parent().move_child(self,self.get_index() - 1)


func onDownPressed():
	self.get_parent().move_child(self,self.get_index() + 1)
