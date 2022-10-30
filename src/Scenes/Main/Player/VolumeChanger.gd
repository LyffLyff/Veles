extends Control

#NODES
onready var VolumeSlider : VSlider = $MarginContainer/Volume/VBoxContainer/Volume


#CONSTANTS

#The higher these values the more the user can get outside of the volume slider before getting freed
const MAX_X_DIFF : int = 100
const MAX_Y_DIFF : int = 140


func _enter_tree():
	Global.root.ToggleSongScrollerInput(false)


func _exit_tree():
	Global.root.ToggleSongScrollerInput(true)


func _ready():
	#Setting the Value of the Slider on ready
	#has to be converted from Db to a linear scale
	VolumeSlider.set_value(db2linear(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"Volume")))


func OnVolumeChanged(var NewVolume : float):
	#Converting the Linear Scale of the Volume Slider to Db Values
	NewVolume = linear2db(NewVolume)
	#Saving the DB Value in the Volume Setting
	SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"Volume",NewVolume)
	MainStream.set_volume_db(NewVolume)


func OnVolumeChangerExited():
	self.queue_free()


func _process(_delta):
	#Extra Safety to be sure this Box will be freed when leaving the area
	#Signals -> not fast enough
	if abs(self.rect_global_position.x - get_global_mouse_position().x) > MAX_X_DIFF:
		OnVolumeChangerExited()
	if self.rect_global_position.y - get_global_mouse_position().y > MAX_Y_DIFF:
		OnVolumeChangerExited()
