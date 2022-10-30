extends Control

#NODES
onready var Rename : Button = $HBoxContainer/VBoxContainer/Rename
onready var ChangeCover : Button = $HBoxContainer/VBoxContainer/ChangeCover
onready var Delete : Button = $HBoxContainer/VBoxContainer/Delete


func _process(var _delta : float):
	if !self.get_global_rect().has_point(get_global_mouse_position()):
		self.queue_free()
