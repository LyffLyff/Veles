extends PanelContainer

signal set_folder_space_idx 

const HIGHLIGHT_CLR : Color = Color("242424")
const NORMAL_CLR : Color = Color("181818")
const TW_DURATION : float = 0.1

var is_highlighted : bool = false

onready var folder_space_label : Label = $HBoxContainer/VBoxContainer/FolderSpace
onready var song_amount_label : Label = $HBoxContainer/VBoxContainer/SongAmount

func _ready():
	self.get_stylebox("panel").set("bg_color", NORMAL_CLR)


func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		_on_FolderSpace_mouse_exited()


func _on_FolderSpace_mouse_entered():
	if !is_highlighted:
		var _tw : PropertyTweener = create_tween().tween_property(self.get_stylebox("panel"), "bg_color", HIGHLIGHT_CLR, TW_DURATION)
		emit_signal("set_folder_space_idx", self.get_index())


func _on_FolderSpace_mouse_exited():
	if !is_highlighted:
		var _tw : PropertyTweener = create_tween().tween_property(self.get_stylebox("panel"), "bg_color", NORMAL_CLR, TW_DURATION)
		emit_signal("set_folder_space_idx", -1)


func pressed() -> void:
	is_highlighted = true
	var _tw : PropertyTweener = create_tween().tween_property(self.get_stylebox("panel"), "bg_color", HIGHLIGHT_CLR, TW_DURATION)


func unhighlight() -> void:
	is_highlighted = false
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", NORMAL_CLR, TW_DURATION )
