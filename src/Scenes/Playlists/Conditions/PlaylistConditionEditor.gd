extends "res://src/Scenes/General/StdPopupBackground.gd"

var playlist_title : String = ""

onready var conditions_list : ScrollContainer = $PanelContainer/MarginContainer/VBoxContainer/PlaylistConditionsList
onready var menu_footer = $PanelContainer/MarginContainer/VBoxContainer/MenuFooter


func _ready():
	menu_footer.connect("save_pressed", self, "_on_Save_pressed")
	menu_footer.connect("close_pressed", self, "_on_Close_pressed")


func init_conditions_editor(var playlist_idx : int) -> void:
	playlist_title = Playlist.get_playlist_name(playlist_idx)
	conditions_list.init_conditions(playlist_title)


func _on_Save_pressed():
	conditions_list.save_conditions()
	self.exit_popup()


func _on_Close_pressed():
	self.exit_popup()
