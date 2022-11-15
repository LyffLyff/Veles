extends OptionButton


func NormalSettingItemSelected(var ItemIdx : int) -> void:
	SettingsData.set_setting(
		get_parent().get_parent().setting_type_idx,
		get_parent().NormalSettingKey,
		ItemIdx
	)
