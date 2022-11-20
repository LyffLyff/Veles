extends Control

onready var info_vbox : VBoxContainer = $HBoxContainer/Sidebar/ScrollContainer/HBoxContainer/InfoVbox
onready var info_text_space : RichTextLabel = $HBoxContainer/VBoxContainer/PanelContainer/InfoTextSpace

func _ready():
	init_infos()


func init_infos() -> void:
	var sub_infos_counter : int = 0
	for i  in info_vbox.get_child_count():
		if info_vbox.get_child(i) is VBoxContainer:
			info_vbox.get_child(i).set("subinfos", info_text_space.infos.values()[sub_infos_counter].size())
			info_vbox.get_child(i).set("subinfo_titles", info_text_space.infos.values()[sub_infos_counter].keys())
			if info_vbox.get_child(i).connect("subinfo_pressed", info_text_space, "set_info_text", [sub_infos_counter]):
				Global.root.message("CANNOT connect Signal subinfo_pressed to info_text_space's set_info_text function",  SaveData.MESSAGE_ERROR )
			sub_infos_counter += 1


func _on_InfoTextSpace_meta_clicked(var meta : String):
	meta = meta.replace("user://", OS.get_user_data_dir())
	var _err = OS.shell_open(str(meta))
