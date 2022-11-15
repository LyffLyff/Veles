extends ColorPickerButton


func _ready():
	#Sets the Color Picker to the Color actual Color Setting
	self.set_pick_color( 
		SettingsData.get_setting(
			get_parent().get_parent().setting_type_idx,
			get_parent().ColorSettingKey
		) 
	)



func _on_ColorSetting_picker_created():
	self.get_picker().rect_size = Vector2(150,300)
