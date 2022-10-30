extends ColorPickerButton


func _ready():
	#Sets the Color Picker to the Color actual Color Setting
	self.set_pick_color( 
		SettingsData.GetSetting(
			get_parent().get_parent().SettingTypeIdx,
			get_parent().ColorSettingKey
		) 
	)



func _on_ColorSetting_picker_created():
	self.get_picker().rect_size = Vector2(150,300)
