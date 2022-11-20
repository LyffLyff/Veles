extends MarginContainer

signal verse_rect_changed
signal verse_text_edited

onready var verse_text_edit : TextEdit = $HBoxContainer/VerseText

func _on_VerseText_text_changed():
	emit_signal("verse_text_edited")
	verse_text_edit.rect_min_size.y = verse_text_edit.get_line_count() * verse_text_edit.get_line_height()


func _on_VerseContainer_item_rect_changed():
	emit_signal("verse_rect_changed", self.get_index(), self.rect_size.y)


func _on_Up_pressed():
	self.get_parent().move_child(self, self.get_index() - 1)


func _on_Down_pressed():
	self.get_parent().move_child(self, self.get_index() + 1)
