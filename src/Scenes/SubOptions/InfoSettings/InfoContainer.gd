extends OptionButton


func NormalSettingItemSelected(var item_idx : int) -> void:
	SettingsData.set_setting(
		get_parent().get_parent().setting_type_idx,
		get_parent().NormalSettingKey,
		item_idx
	)
