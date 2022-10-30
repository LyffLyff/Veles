extends LinkButton


#CONSTANTS
const MAX_CHARACTERS : int = 30;
const CHAR_BUFFER : int = 2
const FONT_RATIO : float = 1.6

#VARIABLES
var uncut_string : String = ""
var cut_string : String = ""


func set_text(var NewText : String) -> void:
	uncut_string = NewText
	set_label()


func get_max_chars() -> int:
	#returns the amount of characters fit in the current space
	#getting the rect_size of parent since then the LinkButton sdon't have to be set on expand
	#meaning they only get a hover and click input when actually being over the text
	return int(get_parent().rect_size.x / self.get_font("font").get_size() * FONT_RATIO) - CHAR_BUFFER


func set_label() -> void:
	#Cuts the String if it won't fit into the Rect
	if uncut_string.length() > get_max_chars():
		cut_string = uncut_string.substr(0,get_max_chars() - 3)
		cut_string += "..."
	else:
		cut_string = uncut_string
	self.text = cut_string


func _on_Parent_Resized():
	#updates the label if the rect changes
	set_label()
