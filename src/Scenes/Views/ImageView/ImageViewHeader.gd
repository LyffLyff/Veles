extends HBoxContainer

signal option_selected

var selected : int = 0

func _ready():
	var skips : int = 0
	for option_button in self.get_children():
		if !option_button is Button:
			skips += 1
			continue
		option_button.connect("pressed", self, "emit_signal", ["option_selected", option_button.get_index() - skips])
		option_button.connect("pressed", self, "highlight_option", [option_button.get_index()])


func highlight_option(var idx : int) -> void:
	self.get_child(selected).set("custom_styles/normal", null)
	selected = idx
	self.get_child(selected).set("custom_styles/normal", load("res://src/Ressources/Themes/TransparentBorder.tres"))
