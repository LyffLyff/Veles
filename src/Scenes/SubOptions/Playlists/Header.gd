extends PanelContainer

func _ready():
	self.get_stylebox("panel").bg_color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "PlaylistHeader")
	#self.material.set(
	#	"shader_param/color",
	#	SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "PlaylistHeader") )
