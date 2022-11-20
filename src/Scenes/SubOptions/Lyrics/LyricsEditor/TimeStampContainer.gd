extends HBoxContainer

signal timestemp_edited

onready var move_up : TextureButton = $MovingUpDown/Up
onready var move_down : TextureButton = $MovingUpDown/Down
onready var timestamp_edit : LineEdit = $TimeInSeconds

func _on_TimeInSeconds_text_changed(var _new_text : String):
	emit_signal("timestemp_edited")
