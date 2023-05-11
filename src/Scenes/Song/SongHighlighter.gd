extends HBoxContainer

onready var panel : PanelContainer = $PanelContainer

func _ready():
	panel.get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS,"SongHighlighter")
	)
	self.hide()
