extends Control

# a variable that saves references to all the File Settings,
# so when files are Dropped they can be handled and entered automatically
var option_file_edits : Array = []
var option_ref : HBoxContainer = null
var design_setter : DesignPaths = null
var changing_stylebox : StyleBox = null
var stylebox_property : String = ""
var picker_clr = null
var setting_key : String = ""
var last_entered_idx : int = -1

onready var option_types : Array = [
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/GeneralSettings.tscn"),
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/SongSettings.tscn"),
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/PlaylistAlbumSettings.tscn"),
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/DesignSettings.tscn"),
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/StatisticSettings.tscn")
]
onready var settings : ScrollContainer = $Select
onready var info_text : RichTextLabel = $VBoxContainer/Info
onready var info_title : Label = $VBoxContainer/InfoTitle
onready var settings_animations : AnimationPlayer = $SettingAnimations

func _ready():
	self.set_process(false)
	load_option(0)
	var _err = get_tree().connect("files_dropped", self, "_on_files_dropped")


func _on_files_dropped(var file_paths : PoolStringArray, var _screen_idx : int) -> void:
	# a function that finds the Closest Reference of a Node inside of an Array,
	# relative to the Mouse Position
	# the Dropped File will then be entered automatically
	if Global.general_dialogue_visible:
		return;
	
	if option_file_edits.size() <= 0:
		return;
	
	var closest_file_edit_idx : int = -1
	var closest_distance : float = -1.0
	
	for i in option_file_edits.size():
		if get_global_mouse_position().distance_to(option_file_edits[i].rect_global_position) < closest_distance or closest_distance == -1.0:
			closest_file_edit_idx = i
			closest_distance = get_global_mouse_position().distance_to(option_file_edits[i].rect_global_position)
	
	option_file_edits[closest_file_edit_idx].file_edit.set_text(file_paths[0])
	option_file_edits[closest_file_edit_idx].file_edit.emit_signal("text_entered",file_paths[0])


func init_current_file_edits() -> void:
	# searching all the File Settings in the Current Settings
	option_file_edits.resize(0)
	
	for i in option_ref.get_child(0).get_child_count():
		if !option_ref.get_child(0).get_child(i).is_in_group("Buffer"):
			if option_ref.get_child(0).get_child(i).setting_type == "File":
				option_file_edits.push_back(option_ref.get_child(0).get_child(i).get_child(2) )


func load_option(var option_idx : int) -> void:
	if settings.get_child_count() > 2:		
		option_ref.queue_free()
	
	option_ref = option_types[option_idx].instance()
	settings.add_child(option_ref)
	
	var option_vbox : VBoxContainer = option_ref.get_child(0)
	
	for n in option_vbox.get_child_count():
		if option_vbox.get_child(n).is_in_group("Buffer"):
			continue;
		
		if option_vbox.get_child(n).get_child(2).connect("mouse_entered",self,"on_option_mouse_entered",[n]):
			Global.message("CONNECTING SETTING CONTAINERS TO MOUSE ENTERED",  Enumerations.MESSAGE_ERROR )
	
		# normal options
		if option_vbox.get_child(n).get_child(2) is OptionButton:
			if option_vbox.get_child(n).get_child(2).has_method("normal_setting_item_selected"):
				if option_vbox.get_child(n).get_child(2).connect("item_selected", option_vbox.get_child(n).get_child(2), "normal_setting_item_selected"):
					Global.message("CONNECTING SETTING CONTAINERS TO PARENTD",  Enumerations.MESSAGE_ERROR )
		
		# design options
		
		if option_vbox.get_child(n).get_child(2) is ColorPickerButton:
			if option_vbox.get_child(n).get_child(2).connect("pressed",self,"on_color_changer_shown",[n]):
				Global.message("COULDN'T CONNECT picker_created SIGNAL TO on_color_changer_shown FUNCTION",  Enumerations.MESSAGE_ERROR )
			if option_vbox.get_child(n).get_child(2).connect("popup_closed",self,"on_color_changer_freed"):
				Global.message("COULDN'T CONNECT popup_closed SIGNAL TO on_color_changer_freed FUNCTION",  Enumerations.MESSAGE_ERROR )
			if option_vbox.get_child(n).get_child(2).connect("color_changed",self,"on_color_changed"):
				Global.message("COULDN'T CONNECT color_changed SIGNAL TO on_color_changed FUNCTION",  Enumerations.MESSAGE_ERROR )
	init_current_file_edits()


func on_option_mouse_entered(var idx : int) -> void:
	if last_entered_idx != idx:
		last_entered_idx = idx
		settings_animations.play("InfoInOut")
		info_title.text = option_ref.get_child(0).infos.keys()[idx]
		info_text.set_bbcode(option_ref.get_child(0).infos.values()[idx])


func on_color_changer_shown(var child_idx : int) -> void:
	design_setter = DesignPaths.new()
	stylebox_property = option_ref.get_child(0).get_child(child_idx).stylebox_clr_property
	setting_key = option_ref.get_child(0).get_child(child_idx).color_setting_key
	
	# setting the Color in realtime
	if option_ref.get_child(0).get_child(child_idx).change_clr_realtime:
		changing_stylebox = Global.root.get_node(option_ref.get_child(0).get_child(child_idx).clr_node_path).get_stylebox(option_ref.get_child(0).get_child(child_idx).stylebox_title)


func on_color_changer_freed() -> void:
	if changing_stylebox:
		SettingsData.set_setting(SettingsData.DESIGN_SETTINGS, setting_key, changing_stylebox.get(stylebox_property) )
	else:
		SettingsData.set_setting(SettingsData.DESIGN_SETTINGS, setting_key, picker_clr)
	picker_clr = null
	design_setter = null
	changing_stylebox = null
	setting_key = ""


func on_color_changed(var clr : Color) -> void:
	if changing_stylebox:
		changing_stylebox.set(stylebox_property,clr)
	else:
		picker_clr = clr
