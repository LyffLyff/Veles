extends HBoxContainer

#Nodes
onready var title : Label = $Label


#General Setting
export var SettingType : String = "Color/Options/File"
export var SettingLabel : String = ""

#Color Setting
export var ColorNodePath : String = ""
export var StyleboxTitle : String = ""
export var StyleboxColorProperty : String = ""
export var ColorSettingKey : String = ""
export var ColorChangeRealtime : bool = true

#Normal Setting
export var NormalSettingKey : String = ""
export var Items : PoolStringArray = [] #title : Idx


#File Setting
export var FileSettingKey : String = ""


#Project Settings
export var ProjectSettingOptions : Array = []

#Section + Key MUST create a property path tp a Project Setting
export var PropertySection : String = "" 
export var PropertyKey : String = ""


func _ready():
	title.set_text(SettingLabel + ": ")
	
	match SettingType:
		"Options":
			var x : OptionButton = load("res://src/Scenes/SubOptions/InfoSettings/InfoContainer.tscn").instance()
			self.add_child(x)
			
			for Idx in Items.size():
				x.add_item(Items[Idx],Idx )
			
			# sets the Info Container to the Current Setting
			x.select(-1)
			x.select( SettingsData.get_setting( get_parent().setting_type_idx, NormalSettingKey ) )
			
		"Color":
			var x : ColorPickerButton = load("res://src/Scenes/SubOptions/InfoSettings/ColorSetting.tscn").instance()
			self.add_child(x)
			x.set_pick_color( SettingsData.get_setting(get_parent().setting_type_idx,ColorSettingKey) )
			
		"File":
			var x : HBoxContainer = load("res://src/Scenes/SubOptions/InfoSettings/SingleFileSetting.tscn").instance()
			self.add_child(x)
		"ProjectSettings":
			var x : OptionButton = load("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/ProjectSettingEdit.tscn").instance()
			self.add_child(x)
		_:
			Global.root.message("INVALID SETTING TYPE",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
