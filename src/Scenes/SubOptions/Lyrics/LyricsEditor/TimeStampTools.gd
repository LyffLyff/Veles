extends VBoxContainer

onready var add_timestamp : TextureButton = $ToolButtons/Add
onready var cut_timestamp : TextureButton = $ToolButtons/Cut
onready var tool_buttons : HBoxContainer = $ToolButtons

func _ready():
	for i in tool_buttons.get_children():
		var _err = i.connect("button_down", Modulator, "modulate_pressed", [i])
		_err = i.connect("mouse_exited", Modulator, "modulate_normal", [i])
		_err = i.connect("button_up", Modulator, "modulate_normal", [i])
		_err = i.connect("mouse_entered", Modulator, "modulate_hover", [i])
