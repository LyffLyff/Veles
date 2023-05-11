extends "res://src/Scenes/General/PlayerOption.gd"

# The higher these values the more the user can get outside of the volume slider before getting freed
const MAX_X_DIFF : int = 80
const MAX_Y_DIFF_TOP : int = -30
const MAX_Y_DIFF_BOTTOM : int = 180

var rel_mouse_pos_y : float

onready var volume_slider : VSlider = $MarginContainer/Volume/VBoxContainer/Volume

func _ready():
	# Setting the Value of the Slider on startup
	init_volume_slider()


func _process(_delta):
	# this process checks the mouse position relative to the volume changer
	# the volume changer will be hidden depending on the difference in position
	
	if abs(self.rect_global_position.x - get_global_mouse_position().x) > MAX_X_DIFF:
		exit_volume_changer()
	
	rel_mouse_pos_y = get_global_mouse_position().y - volume_slider.rect_global_position.y
	if rel_mouse_pos_y < MAX_Y_DIFF_TOP or rel_mouse_pos_y > MAX_Y_DIFF_BOTTOM:
		exit_volume_changer()


func init_volume_slider() -> void:
	volume_slider.set_value(db2linear(SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"Volume")))


func _on_Volume_value_changed(var volume_linear : float):
	MainStream.set_volume(volume_linear)


func exit_volume_changer():
	exit_player_option()
	set_process(false)
