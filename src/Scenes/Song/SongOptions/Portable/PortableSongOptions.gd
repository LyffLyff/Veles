#Portable Song Options
#These Song Options will be revealed as soon as a song is right clicked

extends "res://src/Scenes/Song/SongOptions/SongOptions.gd"


func _ready():
	self.get_stylebox("panel").set_bg_color(
		SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS,"PortableSongOptionsBackground")
	)
