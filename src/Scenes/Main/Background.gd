extends Panel


func _ready():
	self.get_stylebox("panel").set_bg_color(
		SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS,"MainBackgroundColor")
	)
