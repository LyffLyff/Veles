extends PanelContainer


func _ready():
	self.material.set(
		"shader_param/color",
		SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS, "PlaylistHeader") )
