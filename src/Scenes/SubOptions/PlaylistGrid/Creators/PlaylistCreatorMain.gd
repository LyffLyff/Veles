extends "res://src/Scenes/General/StdPopupBackground.gd"

signal close
signal save

onready var footer : Node = self.find_node("MenuFooter", true, true)


func _ready():
	var _err : int = footer.connect("close_pressed", self, "on_close_pressed")


func on_close_pressed() -> void:
	self.emit_signal("close")
	self.exit_popup()
