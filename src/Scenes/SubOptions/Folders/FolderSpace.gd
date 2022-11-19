extends PanelContainer

signal set_folder_space_idx 

const HIGHLIGHT_CLR : Color = Color("161616")
const NORMAL_CLR : Color = Color("222222")
const TW_DURATION : float = 0.15

var is_highlighted : bool = false

onready var folder_space_label : Label = $HBoxContainer/VBoxContainer/FolderSpace
onready var song_amount_label : Label = $HBoxContainer/VBoxContainer/SongAmount

func _ready():
	self.get_stylebox("panel").set("bg_color", NORMAL_CLR)


func _on_FolderSpace_mouse_entered():
	if !is_highlighted:
		var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", HIGHLIGHT_CLR, TW_DURATION)
		emit_signal("set_folder_space_idx",self.get_index())


func _on_FolderSpace_mouse_exited():
	if !is_highlighted:
		var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", NORMAL_CLR, TW_DURATION )
		emit_signal("set_folder_space_idx",-1)


func pressed() -> void:
	is_highlighted = true
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", HIGHLIGHT_CLR, TW_DURATION)


func unhighlight() -> void:
	is_highlighted = false
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", NORMAL_CLR, TW_DURATION )
