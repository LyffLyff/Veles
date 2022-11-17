extends HBoxContainer


func _ready():
	$PanelContainer.get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS,"SongHighlighterColor")
	)
	self.hide()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		self.hide()

