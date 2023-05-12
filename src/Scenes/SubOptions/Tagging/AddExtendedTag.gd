extends "res://src/Scenes/General/StdPopupBackground.gd"

onready var menu_footer = $PanelContainer/MarginContainer/VBoxContainer/MenuFooter
onready var option_button : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/OptionButton
onready var value : TextEdit = $PanelContainer/MarginContainer/VBoxContainer/Value

var audio_filepath : String = ""

func _ready():
	menu_footer.connect("save_pressed", self, "on_save_extended_tag_pressed")
	menu_footer.connect("close_pressed", self, "exit_popup")
	option_button.connect("item_selected", self, "on_identifer_selected")


func init_property_ids(var filepath : String)  -> void:
	audio_filepath = filepath
	var extension : String = filepath.get_extension().to_upper()
	for id in Tagging.new().get_property_identifiers(filepath):
		if id == "":
			continue
		if (extension == "M4A" or extension == "MP4") and id.length() == 3:
			id = "©" + id
		option_button.add_item(id)
	on_identifer_selected(0)


func on_identifer_selected(var identifier_idx : int) -> void:
	value.text = Tagging.new().get_single_text_property(audio_filepath, option_button.get_item_text(identifier_idx))


func on_save_extended_tag_pressed() -> void:
	Tags.set_text_property(value.text, audio_filepath, option_button.get_item_text(option_button.get_selected()))
	exit_popup()
