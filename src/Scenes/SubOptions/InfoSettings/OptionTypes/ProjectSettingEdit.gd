extends OptionButton


func _ready():
	var SettingValue = SaveData.GetConfigValue(get_parent().PropertySection,get_parent().PropertyKey)
	
	for i in get_parent().Items.size():
		self.add_item( var2str( get_parent().ProjectSettingOptions[i] ) )
		#if typeof(get_parent().Items[i]) == typeof(SettingValue):
		
		if typeof(get_parent().ProjectSettingOptions[i]) == typeof(SettingValue):
			if get_parent().ProjectSettingOptions[i] == SettingValue:
				self.select(i)


func OnProjectSettingEditItemSelected(var idx : int):
	SaveData.SetConfigValue(
		get_parent().PropertySection,
		get_parent().PropertyKey,
		get_parent().ProjectSettingOptions[idx]
	)
