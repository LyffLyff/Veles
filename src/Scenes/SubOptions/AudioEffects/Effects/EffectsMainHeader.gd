extends PanelContainer


#NODES
onready var AddPreset : TextureButton = $VBoxContainer/HBoxContainer/AddPreset
onready var Close : TextureButton = $VBoxContainer/HBoxContainer/Close
onready var PresetSelection : MenuButton = $VBoxContainer/HBoxContainer/PresetSelection


func _enter_tree():
	InitColor()


func _ready():
	InitPresetSelection()


func InitColor() -> void:
	self.get_stylebox("panel").set_bg_color( SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS, "AudioEffectsHeaderBackground") )


func InitPresetSelection() -> void:
	var dir : Directory = Directory.new()
	if dir.open(Global.GetCurrentUserDataFolder() + "/Settings/AudioEffects/Presets") != OK:
		Global.root.Message("OPENING PRESETS FOLDER",  SaveData.MESSAGE_ERROR)
		return;
	
	if dir.list_dir_begin(true,true) != OK:
		return
	
	var PresetPopup : PopupMenu = PresetSelection.get_popup()
	
	#Deleting all prior items
	PresetPopup.clear()
	
	
	var ItemIdx : int = 0
	var TempFilename : String = ""
	
	while true:
		TempFilename = dir.get_next()
		if TempFilename == "":
			break;
		if TempFilename.get_extension() != "epr":
			#filtering invalid files -> everything not preset
			continue;
		
		PresetPopup.add_item( TempFilename , ItemIdx)
		PresetPopup.set_item_text(ItemIdx, TempFilename)
		ItemIdx += 1
