extends "res://src/Scenes/Templates/MovingContainer.gd"

const TW_DURATION : float = 0.15

var artist : String = ""

onready var artist_label : Label = $HBoxContainer/Info/Name
onready var profession_label : Label = $HBoxContainer/Info/Profession
onready var button : Button = $ArtistButton
onready var hold_threshold_timer : Timer = $HoldThresholdTimer
onready var cover : TextureRect = $HBoxContainer/Artist

func _input(event):
	if event is InputEventMouseButton:
			if !event.is_pressed():
				if event.button_index == BUTTON_LEFT:
					if is_holding:
						is_holding = false
						self.emit_signal("moving_container_released")


func init_artist_space(var artist_name : String, var profession : String = "") -> void:
	artist = artist_name
	artist_label.text = artist_name
	yield(get_tree(), "idle_frame")
	cover.texture = ImageLoader.get_cover(Global.get_current_user_data_folder() + "/Songs/Artists/Covers/" + artist + ".png", ImageLoader.ImageTypes.ARTIST, "", Vector2(cover.rect_size.y, cover.rect_size.y))

	profession_label.set_text(profession)
	hold_threshold_timer.set_wait_time(HOLD_THRESHOLD)


func _on_ArtistButton_button_up():
	if !is_holding:
		emit_signal("moving_container_pressed", artist)


func _on_ArtistButton_button_down():
	is_holding = false
	hold_threshold_timer.start()
	yield(hold_threshold_timer, "timeout")
	if button.is_pressed():
		# if the Button is still Down after threshold period it counts as holding this button
		is_holding = true
		# getting Index in Parent here since it can change
		emit_signal("moving_container_held", self.get_index())


func _on_ArtistSpace_mouse_entered():
	self.set("custom_styles/panel", load("res://src/Ressources/Themes/Text/Focused.tres"))


func _on_ArtistSpace_mouse_exited():
	self.set("custom_styles/panel", load("res://src/Ressources/Themes/Text/Normal.tres"))
