extends "res://src/Scenes/Song/SongOptions/SongOptions.gd"
# portable Song Options
# these Song Options will be revealed as soon as a song is right clicked


func _ready():
	self.get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS,"PortableSongOptionsBackground")
	)
