extends MenuButton


#VARIABLES
var MenuButtonSelections : Array = []


func _ready():
	var _err = self.get_popup().connect("id_pressed",self,"OnMenuIdPressed")
	self.get_popup().allow_search = true
	#Adding the Option to always select an Empty Option
	MenuButtonSelections.push_front("")
	
	#Adding the Items that are inside the MenuButtons Array
	for i in MenuButtonSelections.size():
		self.get_popup().add_item(
			MenuButtonSelections[i],
			i
		)


func OnMenuIdPressed(var id : int) -> void:
	self.set_text(
		self.get_popup().get_item_text(id)
	)
