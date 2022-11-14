extends "res://src/Scenes/General/PlayerOption.gd"


#NODES
onready var OutputDevices : VBoxContainer = $HBoxContainer/VBoxContainer/HBoxContainer/ScrollContainer/OutputDevices


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


func _ready():
	var OutputDeviceNames : PoolStringArray = AudioServer.get_device_list()
	for OutputDevice in OutputDeviceNames:
		var x : Button = Button.new()
		var y : Label = Label.new()
		if x.connect("pressed",AudioServer,"set_device",[OutputDevice]):
			Global.root.message("COULD NOT CONNECT pressed SIGNAL to AudioServer set_device()", SaveData.MESSAGE_ERROR)
		if x.connect("pressed",SettingsData,"SetSetting",[SettingsData.GENERAL_SETTINGS, "AudioOutputDevice", OutputDevice]):
			Global.root.message("CONNECTING SET SETTING OF AUDIO OUTPUT DEVICE", SaveData.MESSAGE_ERROR)
		if x.connect("pressed",self,"queue_free"):
			Global.root.message("COULD NOT CONNECT pressed SIGNAL to queue_free()", SaveData.MESSAGE_ERROR)
		OutputDevices.add_child(x)
		y.autowrap = true
		if OutputDevice == AudioServer.get_device():
			x.set_deferred("custom_styles/normal",load("res://src/Ressources/Themes/Song/HighlightedSong.tres") )
		else:
			x.set_deferred("custom_styles/normal",StyleBoxEmpty.new())
		x.set_deferred("custom_styles/hover",load("res://src/Ressources/Themes/Song/HighlightedSong.tres") )
		x.set_deferred("custom_styles/pressed",load("res://src/Ressources/Themes/Song/HighlightedSong.tres") )
		x.set_deferred("custom_styles/focus",load("res://src/Ressources/Themes/Song/HighlightedSong.tres") )
		y.set_align(Label.ALIGN_CENTER)
		y.set_anchors_and_margins_preset(Control.PRESET_WIDE)
		y.valign = Label.ALIGN_CENTER
		x.rect_min_size.y = 40
		x.size_flags_horizontal = SIZE_EXPAND
		x.rect_min_size.x = self.rect_size.x - 10
		y.set_text( OutputDevice )
		x.add_child(y)


func _process(_delta):
	if !self.get_global_rect().has_point( get_global_mouse_position() ):
		ExitPlayerOption()
		set_process(false)
