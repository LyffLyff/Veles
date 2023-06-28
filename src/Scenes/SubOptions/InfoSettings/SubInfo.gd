extends VBoxContainer

signal subinfo_pressed

const PLUS_TEXTURE : StreamTexture = preload("res://src/assets/Icons/White/General/add_1_72px.png")
const MINUS_TEXTURE : StreamTexture = preload("res://src/assets/Icons/White/General/remove_1_72px.png")

export var subinfo_title : String = ""

var is_subinfo_expanded : bool = false
var subinfos : int = -1
var subinfo_titles : PoolStringArray = []

onready var subinfo_main : Button = $SubInfoMain
onready var subinfo_vbox : VBoxContainer = $HBoxContainer/SubInfoVBox
onready var expandable_space : HBoxContainer = $HBoxContainer

func _ready():
	subinfo_main.set_text(subinfo_title)


func load_subinfos() -> void:
	for i in subinfos:
		var x : Button = Button.new()
		x.align = Button.ALIGN_LEFT
		x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if x.connect("pressed" ,self, "emit_signal", ["subinfo_pressed",i]):
			Global.message("CANNOT CONNECT pressed signal to emit_signal subinfo_pressed",  Enumerations.MESSAGE_ERROR)
		x.theme = load("res://src/Themes/Buttons/ClearButtons.tres")
		x.align = Button.ALIGN_CENTER
		x.rect_min_size.y = 25
		x.set_text(subinfo_titles[i])
		subinfo_vbox.add_child(x)


func unload_subinfos() -> void:
	for n in subinfo_vbox.get_children():
		subinfo_vbox.remove_child(n)
		n.queue_free()


func toggle_subinfo() -> void:
	is_subinfo_expanded =  !is_subinfo_expanded
	if !is_subinfo_expanded:
		unload_subinfos()
		subinfo_main.icon = PLUS_TEXTURE
	else:
		load_subinfos()
		subinfo_main.icon = MINUS_TEXTURE
	expandable_space.set_visible(is_subinfo_expanded)


func _on_SubInfoMain_pressed():
	toggle_subinfo()

