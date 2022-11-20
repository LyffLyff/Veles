extends PanelContainer

func _ready():
	self.material.set(
		"shader_param/color",
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "PlaylistHeader") )
