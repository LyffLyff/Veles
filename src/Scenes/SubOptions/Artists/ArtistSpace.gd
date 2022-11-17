extends "res://src/Scenes/Templates/MovingContainer.gd"


#NODES
onready var ArtistNameLabel : Label = $HBoxContainer/Info/Name
onready var ArtistProfessionLabel : Label = $HBoxContainer/Info/Profession
onready var ArtistButton : Button = $ArtistButton
onready var HoldThresholdTimer : Timer = $HoldThresholdTimer
onready var ArtistCover : TextureRect = $HBoxContainer/Artist

#CONSTANTS
const highlight_clr : Color = Color("161616")
const normal_clr : Color = Color("222222")
const TW_DURATION : float = 0.15

#VARIABLES
var artists : PoolStringArray = []


func InitArtistSpace(var ArtistNames : PoolStringArray, var ArtistProfession : String) -> void:
	self.get_stylebox("panel").set_bg_color(normal_clr)
	artists = ArtistNames
	ArtistCover.set_texture( ImageLoader.get_cover(Global.get_current_user_data_folder() + "/Songs/Artists/Covers/" + ArtistNames.join("") + ".png") )
	ArtistNameLabel.set_text( ArtistNames.join(", ") )
	ArtistProfessionLabel.set_text( ArtistProfession )
	HoldThresholdTimer.set_wait_time(HOLD_THRESHOLD)


func OnArtistButtonButtonUp():
	if !is_holding:
		emit_signal("moving_container_pressed", artists )


func OnArtistButtonButtonDown():
	is_holding = false
	HoldThresholdTimer.start()
	yield(HoldThresholdTimer,"timeout")
	if ArtistButton.is_pressed():
		#if the Button is still Down after threshold period it counts as holding this button
		is_holding = true
		
		#Getting Index in Parent here since it can change
		emit_signal("moving_container_held", self.get_index() )


func _input(event):
	if event is InputEventMouseButton:
			if !event.is_pressed():
				if event.button_index == BUTTON_LEFT:
					if is_holding:
						is_holding = false
						emit_signal("moving_container_released")


func _on_ArtistSpace_mouse_entered():
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", highlight_clr, TW_DURATION)


func _on_ArtistSpace_mouse_exited():
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", normal_clr, TW_DURATION )
