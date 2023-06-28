extends PanelContainer

signal set_folder_space_idx 

const HIGHLIGHT_CLR : Color = Color("242424")
const NORMAL_CLR : Color = Color("181818")
const TW_DURATION : float = 0.1

var is_highlighted : bool = false

onready var folder_space_label : Label = $HBoxContainer/VBoxContainer/FolderSpace
onready var song_amount_label : Label = $HBoxContainer/VBoxContainer/SongAmount


func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		_on_FolderSpace_mouse_exited()


func _on_FolderSpace_mouse_entered():
	if !is_highlighted:
		self.set("custom_styles/panel", load("res://src/Ressources/Themes/Text/Focused.tres"))
		emit_signal("set_folder_space_idx", self.get_index())


func _on_FolderSpace_mouse_exited():
	if !is_highlighted:
		self.set("custom_styles/panel", load("res://src/Ressources/Themes/Text/Normal.tres"))
		emit_signal("set_folder_space_idx", -1)


func pressed() -> void:
	is_highlighted = true


func unhighlight() -> void:
	is_highlighted = false
	self.set("custom_styles/panel", load("res://src/Ressources/Themes/Text/Normal.tres"))
