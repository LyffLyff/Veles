extends "res://src/Scenes/Templates/MovingContainer.gd"

const HIGHLIGHT_CLR : Color = Color("161616")
const NORMAL_CLR : Color = Color("222222")
const TW_DURATION : float = 0.15

var artists : PoolStringArray = []

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
						emit_signal("moving_container_released")


func init_artist_space(var artists : PoolStringArray, var profession : String) -> void:
	self.get_stylebox("panel").set_bg_color(NORMAL_CLR)
	self.artists = artists
	cover.set_texture( ImageLoader.get_cover(Global.get_current_user_data_folder() + "/Songs/Artists/Covers/" + artists.join("") + ".png") )
	artist_label.set_text( self.artists.join(", ") )
	profession_label.set_text( profession )
	hold_threshold_timer.set_wait_time(HOLD_THRESHOLD)


func _on_ArtistButton_button_up():
	if !is_holding:
		emit_signal("moving_container_pressed", artists)


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
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", HIGHLIGHT_CLR, TW_DURATION)


func _on_ArtistSpace_mouse_exited():
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", NORMAL_CLR, TW_DURATION )
