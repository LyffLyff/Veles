extends VBoxContainer


#NODES
onready var AddVerse : TextureButton = $ToolButtons/Add
onready var CutVerse : TextureButton = $ToolButtons/Cut
onready var ToolButtons : HBoxContainer = $ToolButtons


func _ready():
	for i in ToolButtons.get_children():
		var _err = i.connect("button_down", Modulator, "modulate_pressed", [i])
		_err = i.connect("mouse_exited", Modulator, "modulate_normal", [i])
		_err = i.connect("button_up", Modulator, "modulate_normal", [i])
		_err = i.connect("mouse_entered", Modulator, "modulate_hover", [i])
