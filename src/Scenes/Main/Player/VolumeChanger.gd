extends "res://src/Scenes/General/PlayerOption.gd"

#NODES
onready var VolumeSlider : VSlider = $MarginContainer/Volume/VBoxContainer/Volume


#CONSTANTS
#The higher these values the more the user can get outside of the volume slider before getting freed
const MAX_X_DIFF : int = 80
const MAX_Y_DIFF_TOP : int = -30
const MAX_Y_DIFF_BOTTOM : int = 180

#VARIABLES
var temp : float


func _enter_tree():
	Global.root.ToggleSongScrollerInput(false)


func _exit_tree():
	Global.root.ToggleSongScrollerInput(true)


func _ready():
	#Setting the Value of the Slider on startup
	init_volume_slider()


func init_volume_slider() -> void:
	VolumeSlider.set_value(
		db2linear(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"Volume"))
	)


func OnVolumeChanged(var volume_linear : float):
	MainStream.set_volume(volume_linear)


func OnVolumeChangerExited():
	ExitPlayerOption()
	set_process(false)


func _process(_delta):
	#Extra Safety to be sure this Box will be freed when leaving the area
	#Signals -> not fast enough
	if abs(self.rect_global_position.x - get_global_mouse_position().x) > MAX_X_DIFF:
		OnVolumeChangerExited()
	temp = get_global_mouse_position().y - VolumeSlider.rect_global_position.y
	if temp < MAX_Y_DIFF_TOP or temp > MAX_Y_DIFF_BOTTOM:
		OnVolumeChangerExited()
