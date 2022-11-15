extends "res://src/Scenes/General/PlayerOption.gd"

onready var output_devices : VBoxContainer = $HBoxContainer/VBoxContainer/HBoxContainer/ScrollContainer/OutputDevices

func _ready():
	var output_device_names : PoolStringArray = AudioServer.get_device_list()
	for output_device in output_device_names:
		var x : Button = Button.new()
		var y : Label = Label.new()
		if x.connect("pressed",AudioServer,"set_device",[output_device]):
			Global.root.message("COULD NOT CONNECT pressed SIGNAL to AudioServer set_device()", SaveData.MESSAGE_ERROR)
		if x.connect("pressed",SettingsData,"set_setting",[SettingsData.GENERAL_SETTINGS, "AudioOutputDevice", output_device]):
			Global.root.message("CONNECTING SET SETTING OF AUDIO OUTPUT DEVICE", SaveData.MESSAGE_ERROR)
		if x.connect("pressed",self,"queue_free"):
			Global.root.message("COULD NOT CONNECT pressed SIGNAL to queue_free()", SaveData.MESSAGE_ERROR)
		output_devices.add_child(x)
		y.autowrap = true
		if output_device == AudioServer.get_device():
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
		y.set_text( output_device )
		x.add_child(y)


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


func _process(_delta):
	if !self.get_global_rect().has_point( get_global_mouse_position() ):
		exit_player_option()
		set_process(false)
