extends VBoxContainer

signal update_cover
signal cover_updated

var current_cover_idx : int = -1
var covers_amount : int = -1

onready var prior : TextureButton = $HBoxContainer/Prior
onready var next : TextureButton = $HBoxContainer/Next
onready var current_cover_label : Label = $HBoxContainer/CurrentCover
onready var option_hbox : HBoxContainer = $HBoxContainer
onready var cover : TextureButton = $Cover


func _notification(what):
	# blocking input when window is out of focus
	if what == NOTIFICATION_WM_FOCUS_OUT:
		self.set_deferred("disabled", true)
	elif what == NOTIFICATION_WM_FOCUS_IN:
		self.set_deferred("disabled", false)


func update_cover(var new_cover : Texture, var cover_idx : int = -1, var embedded_covers : int = -1) -> void:
	# init
	self.covers_amount = embedded_covers
	option_hbox.visible = (covers_amount > 1)
	current_cover_idx = cover_idx
	
	# current cover label
	current_cover_label.text = str(cover_idx + 1) + "/" + str(covers_amount)
	
	# set cover
	cover.texture_normal = ImageLoader.resize_texture(
		new_cover,
		Vector2(cover.rect_size.x, cover.rect_size.x) if cover.rect_size.x > cover.rect_size.y else Vector2(cover.rect_size.y, cover.rect_size.y)
	)
	
	self.emit_signal("cover_updated")


func set_cover_idx(var diff : int) -> void:
	current_cover_idx += diff
	current_cover_idx = int(clamp(current_cover_idx, 0, covers_amount))
	self.emit_signal("update_cover", current_cover_idx)


func get_center_color() -> Color:
	#  returns color of the pixel in the center of the cover
	var cover_img : Image = cover.get_normal_texture().get_data()
	var single_clr : Color = Color("ffffffff")
	if cover_img:
		cover_img.lock()
		single_clr = cover_img.get_pixelv(cover_img.get_size() / 2)
	return single_clr.darkened(0.5)


func _on_Prior_pressed():
	set_cover_idx(-1)


func _on_Next_pressed():
	set_cover_idx(+1)


func _on_Next_button_down():
	Modulator.modulate_pressed(next)


func _on_Prior_button_down():
	Modulator.modulate_pressed(prior)


func _on_Next_button_up():
	Modulator.modulate_normal(next)


func _on_Prior_button_up():
	Modulator.modulate_normal(prior)
