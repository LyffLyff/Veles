extends HBoxContainer


#SIGNALS
signal OptionButtonPressed

#VARIABLES
var SelectedOptionIdx : int = 0


func _ready():
	var _err
	for i in self.get_child_count():
		_err = self.get_child(i).connect("pressed",self,"emit_signal",["OptionButtonPressed",i])
		_err = self.get_child(i).connect("pressed",self,"SelectedOption",[i])
	SelectedOption(0)


func SelectedOption(var OptionIdx : int) -> void:
	self.get_child( SelectedOptionIdx ).set("custom_styles/normal",null)
	SelectedOptionIdx = OptionIdx
	self.get_child( SelectedOptionIdx ).set("custom_styles/normal",load("res://src/Themes/Buttons/ClearButtonPressed.tres"))
