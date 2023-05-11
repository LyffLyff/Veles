extends "res://src/Scenes/General/StdPopupBackground.gd"

onready var divided_container : Control = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Tags/DividedContainer
onready var options : VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Options
onready var menu_footer : Control = $PanelContainer/MarginContainer/VBoxContainer/MenuFooter

var filepath : String = ""

func _ready():
	for option_button in options.get_children():
		Modulator.init_modulation(option_button)
	Global.root.init_context_menus()
	menu_footer.connect("save_pressed", self, "exit_popup")
	menu_footer.connect("close_pressed", self, "exit_popup")
	divided_container.connect("item_doubleclicked", self, "edit_extended_tag")
	# Init Headers
	var headers : PoolStringArray = ["TITLE", "VALUE"]
	for i in range(len(headers)):
		divided_container.append_section(false, "", 0)
		divided_container.set_header(i, headers[i])
	divided_container.toggle_editable_separators(false)


func init_extended_tag_editor(var path : String) -> void:
	filepath = path
	var tags : Dictionary = Tags.get_text_properties(path)
	divided_container.clear_items()
	for i in tags.size():
		divided_container.append_item([tags.keys()[i], tags.values()[i]])


func edit_extended_tag(var item_idx : int) -> void:
	var ref : Control = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	Global.overlay_menu(ref)
	
	var values : PoolStringArray = divided_container.get_item_values(item_idx + 1)
	ref.set_topic(values[0])
	ref.set_default_value(values[1])
	ref.connect("text_saved", Tags, "set_text_property", [filepath, values[0]])
	ref.connect("text_saved", self, "update_tag", [values[0], item_idx], CONNECT_DEFERRED)


func update_tag(var new_value : String, var property_id : String, var item_idx : int) -> void:
	divided_container.set_item_values(item_idx + 1, [property_id, new_value])


func _on_Remove_pressed():
	Tagging.new().remove_text_property(filepath, divided_container.get_selected_item_values()[0])
	init_extended_tag_editor(filepath)


func _on_Edit_pressed():
	edit_extended_tag(divided_container.focused_item_idx - 1)


func _on_Add_pressed():
	var ref : Control = load("res://src/Scenes/SubOptions/Tagging/AddExtendedTag.tscn").instance()
	Global.overlay_menu(ref)
	ref.init_property_ids(filepath)
	ref.connect("popup_exited", self, "init_extended_tag_editor", [filepath])
