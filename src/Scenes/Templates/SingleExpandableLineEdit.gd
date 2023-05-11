extends HBoxContainer

signal add_pressed
signal remove_pressed

const remove : StreamTexture = preload("res://src/Assets/Icons/White/General/Minus128px.png")

onready var line_edit : LineEdit = $LineEdit
onready var icon : TextureButton = $AddRemove

func _ready():
	Modulator.init_modulation(icon)
	if self.get_index() > 0:
		self.icon.texture_normal = remove


func _on_LineEdit_text_entered(var _new_text : String):
	line_edit.release_focus()


func _on_AddRemove_pressed():
	self.emit_signal("remove_pressed", self.get_index())
	self.emit_signal("add_pressed")
