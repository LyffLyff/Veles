extends Panel


func _ready():
	self.get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "MainBackgroundColor")
	)
