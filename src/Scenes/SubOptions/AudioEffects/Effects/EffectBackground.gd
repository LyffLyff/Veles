extends PanelContainer


func _enter_tree():
	self.get_stylebox("panel").set_bg_color( 
		SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS, "AudioEffectsBackground")
	)
