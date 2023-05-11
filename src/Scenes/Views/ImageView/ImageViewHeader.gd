extends HBoxContainer

signal option_selected

func _ready():
	var skips : int = 0
	for option_button in self.get_children():
		if !option_button is Button:
			skips += 1
			continue
		option_button.connect("pressed", self, "emit_signal", ["option_selected", option_button.get_index() - skips])
