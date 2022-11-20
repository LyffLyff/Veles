extends MenuButton

var menu_button_selections : Array = []

func _ready():
	var _err = self.get_popup().connect("id_pressed",self,"_on_menu_id_pressed")
	self.get_popup().allow_search = true
	# adding the Option to always select an Empty Option
	menu_button_selections.push_front("")
	
	# adding the items that are inside the MenuButtons Array
	for i in menu_button_selections.size():
		self.get_popup().add_item(
			menu_button_selections[i],
			i
		)


func _on_menu_id_pressed(var id : int) -> void:
	self.set_text(
		self.get_popup().get_item_text(id)
	)
