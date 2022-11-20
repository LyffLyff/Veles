extends OptionButton


func _ready():
	var setting_value = SaveData.get_config_value(get_parent().property_section,get_parent().property_key)
	
	for i in get_parent().items.size():
		self.add_item( var2str( get_parent().project_setting_options[i] ) )
		#if typeof(get_parent().items[i]) == typeof(setting_value):
		
		if typeof(get_parent().project_setting_options[i]) == typeof(setting_value):
			if get_parent().project_setting_options[i] == setting_value:
				self.select(i)


func OnProjectSettingEditItemSelected(var idx : int):
	SaveData.set_config_value(
		get_parent().property_section,
		get_parent().property_key,
		get_parent().project_setting_options[idx]
	)
