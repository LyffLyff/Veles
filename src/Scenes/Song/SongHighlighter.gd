extends HBoxContainer


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		self.hide()


func _ready():
	$PanelContainer.get_stylebox("panel").set_bg_color(
		SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS,"SongHighlighterColor")
	)
	self.hide()
