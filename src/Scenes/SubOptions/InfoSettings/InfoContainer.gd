extends OptionButton


func NormalSettingItemSelected(var ItemIdx : int) -> void:
	SettingsData.SetSetting(
		get_parent().get_parent().SettingTypeIdx,
		get_parent().NormalSettingKey,
		ItemIdx
	)
