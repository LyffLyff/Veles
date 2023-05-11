extends HBoxContainer

# General Setting
export var setting_type : String = "Color/Options/File"
export var setting_label : String = ""

# Color Setting
export var clr_node_path : String = ""
export var stylebox_title : String = ""		#panel, bg,....
export var stylebox_clr_property : String = ""
export var color_setting_key : String = ""
export var change_clr_realtime : bool = true

# Normal Setting
export var normal_setting_key : String = ""
export var items : PoolStringArray = [] #title : idx

# File Setting
export var file_setting_key : String = ""

# Project Settings
export var project_setting_options : Array = []

# Section + Key MUST create a property path tp a Project Setting
export var property_section : String = "" 
export var property_key : String = ""

onready var title : Label = $Label

func _ready():
	title.set_text(setting_label + ": ")
	match setting_type:
		"Options":
			var x : OptionButton = load("res://src/Scenes/SubOptions/InfoSettings/InfoContainer.tscn").instance()
			self.add_child(x)
			
			for idx in items.size():
				x.add_item(items[idx], idx)
			
			# sets the Info Container to the Current Setting
			x.select(-1)
			x.select(SettingsData.get_setting(get_parent().setting_type_idx, normal_setting_key))
			
		"Color":
			var x : ColorPickerButton = load("res://src/Scenes/SubOptions/InfoSettings/ColorSetting.tscn").instance()
			self.add_child(x)
			x.set_pick_color(SettingsData.get_setting(get_parent().setting_type_idx, color_setting_key))
			
		"File":
			var x : HBoxContainer = load("res://src/Scenes/SubOptions/InfoSettings/SingleFileSetting.tscn").instance()
			self.add_child(x)
		"ProjectSettings":
			var x : OptionButton = load("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/ProjectSettingEdit.tscn").instance()
			self.add_child(x)
		_:
			Global.message("INVALID SETTING TYPE",  Enumerations.MESSAGE_ERROR, true)
