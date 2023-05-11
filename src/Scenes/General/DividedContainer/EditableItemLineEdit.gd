extends "res://src/Scenes/General/OutsideInputCheck.gd"

signal item_edit_exit

onready var line_edit : LineEdit = $"."

func _ready():
	self.connect("outside_input", self, "queue_free")


func _exit_tree():
	self.emit_signal("item_edit_exit", line_edit.get_text())
