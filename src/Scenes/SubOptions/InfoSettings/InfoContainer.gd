extends OptionButton


func normal_setting_item_selected(var item_idx : int) -> void:
	SettingsData.set_setting(
		get_parent().get_parent().setting_type_idx,
		get_parent().normal_setting_key,
		item_idx
	)
