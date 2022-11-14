extends PanelContainer

#SIGNALS
signal SetFolder 

#NODES
onready var FolderLabel : Label = $HBoxContainer/VBoxContainer/FolderSpace
onready var SongAmountLabel : Label = $HBoxContainer/VBoxContainer/SongAmount

#CONSTANTS
const highlight_clr : Color = Color("161616")
const normal_clr : Color = Color("222222")
const TW_DURATION : float = 0.15

#VARIABLES
var highlighted : bool = false


func _ready():
	self.get_stylebox("panel").set("bg_color",normal_clr)


func _on_FolderSpace_mouse_entered():
	if !highlighted:
		var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", highlight_clr, TW_DURATION)
		emit_signal("SetFolder",self.get_index())


func _on_FolderSpace_mouse_exited():
	if !highlighted:
		var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", normal_clr, TW_DURATION )
		emit_signal("SetFolder",-1)


func Pressed() -> void:
	highlighted = true
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", highlight_clr, TW_DURATION)


func Unhighlight() -> void:
	highlighted = false
	var _tw : PropertyTweener = create_tween().tween_property( self.get_stylebox("panel"), "bg_color", normal_clr, TW_DURATION )
