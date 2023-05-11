extends PanelContainer

var presets : PoolStringArray = []

onready var add_preset : TextureButton = $VBoxContainer/HBoxContainer/AddPreset
onready var close : TextureButton = $VBoxContainer/HBoxContainer/Close
onready var preset_menu : MenuButton = $VBoxContainer/HBoxContainer/PresetSelection

func _ready():
	init_preset_selection()


func _enter_tree():
	init_color()


func init_color() -> void:
	self.get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "AudioEffectsBackground")
	)


func init_preset_selection() -> void:
	var dir : Directory = Directory.new()
	if dir.open(Global.get_current_user_data_folder() + "/Settings/AudioEffects/Presets") != OK:
		Global.message("OPENING PRESETS FOLDER",  Enumerations.MESSAGE_ERROR)
		return;
	
	if dir.list_dir_begin(true,true) != OK:
		return
	
	var preset_popup : PopupMenu = preset_menu.get_popup()
	
	# deleting all prior items
	preset_popup.clear()
	
	
	var item_idx : int = 0
	var temp_filename : String = ""
	
	while true:
		temp_filename = dir.get_next()
		if temp_filename == "":
			break;
		if temp_filename.get_extension() != "epr":
			#filtering invalid files -> everything not preset
			continue;
		
		presets.push_back(temp_filename.trim_suffix(".epr"))
		preset_popup.add_item(temp_filename, item_idx)
		preset_popup.set_item_text(item_idx, temp_filename)
		item_idx += 1


func _on_Close_mouse_entered():
	Modulator.modulate_hover(close)


func _on_Close_mouse_exited():
	Modulator.modulate_normal(close)


func _on_AddPreset_mouse_entered():
	Modulator.modulate_hover(add_preset)


func _on_AddPreset_mouse_exited():
	Modulator.modulate_normal(add_preset)
