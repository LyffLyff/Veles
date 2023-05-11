extends "res://src/Scenes/General/MovablePopupMenu.gd"

onready var output_devices : VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/OutputDevices

func _ready():
	var output_device_names : PoolStringArray = AudioServer.get_device_list()
	for output_device in output_device_names:
		var b := Button.new()
		b.size_flags_vertical = 0 
		b.size_flags_horizontal = SIZE_EXPAND_FILL
		output_devices.add_child(b)
		
		if b.connect("pressed", AudioServer, "set_device",[output_device]):
			Global.message("COULD NOT CONNECT pressed SIGNAL to AudioServer set_device()", Enumerations.MESSAGE_ERROR)
		if b.connect("pressed",SettingsData,"set_setting",[SettingsData.GENERAL_SETTINGS, "AudioOutputDevice", output_device]):
			Global.message("CONNECTING SET SETTING OF AUDIO OUTPUT DEVICE", Enumerations.MESSAGE_ERROR)
		if b.connect("pressed",self,"unload_popup"):
			Global.message("COULD NOT CONNECT pressed SIGNAL to queue_free()", Enumerations.MESSAGE_ERROR)

		var l := RichTextLabel.new()
		l.bbcode_enabled = true
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.set_anchors_and_margins_preset(Control.PRESET_WIDE) 
		l.rect_position.y = 5
		l.bbcode_text =  "[center]" + output_device
		b.add_child(l)

		yield(get_tree(), "idle_frame")
		b.rect_min_size.y = l.get_content_height() + 10
