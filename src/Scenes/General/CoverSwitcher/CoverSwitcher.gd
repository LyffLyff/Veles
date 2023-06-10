extends MarginContainer

signal left_clicked
signal right_clicked
signal prior
signal next
signal cover_updated

onready var cover : TextureRect = $VBoxContainer/Cover
onready var prior : TextureButton = $VBoxContainer/SwitchButtons/Prior
onready var next : TextureButton = $VBoxContainer/SwitchButtons/Next
onready var current_idx : Label = $VBoxContainer/SwitchButtons/Counter
onready var max_covers : Label = $VBoxContainer/SwitchButtons/Max

var cover_idx : int = 0
var current_covers : Array = []


func _ready():
	Modulator.init_modulation(prior)
	Modulator.init_modulation(next)


func _on_Cover_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				BUTTON_LEFT:
					self.emit_signal("left_clicked")
				BUTTON_RIGHT:
					self.emit_signal("right_clicked")


func _on_Prior_pressed():
	self.emit_signal("prior")
	cover_idx -= 1
	if cover_idx < 0:
		cover_idx = 0 
	update_cover()


func _on_Next_pressed():
	self.emit_signal("next")
	cover_idx += 1
	if cover_idx >= current_covers.size():
		cover_idx = current_covers.size() - 1
	update_cover()


func update_cover_number() -> void:
	# set cover switcher values
	if current_covers.size() == 0:
		current_idx.text = "0"
		max_covers.text = "X"
	else:
		current_idx.text = str(cover_idx + 1)
		max_covers.text = str(current_covers.size())


func set_covers(var covers : Array) -> void:
	current_covers = covers
	cover_idx = 0
	update_cover()


func update_cover() -> void:
	if current_covers.size() > 0:
		cover.texture = ImageLoader.resize_texture(current_covers[cover_idx], Vector2(cover.rect_size.y, cover.rect_size.y))
	else:
		cover.texture = load("res://src/assets/Icons/White/Tagging/cd_128px.png")
	update_cover_number()
	emit_signal("cover_updated", cover_idx)
