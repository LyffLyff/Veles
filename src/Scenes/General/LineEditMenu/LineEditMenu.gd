extends "res://src/Scenes/General/OutsideInputCheck.gd"

signal expand_menu_hidden
signal menu_to_be_shown
signal menu_button_pressed

const menu_button : PackedScene = preload("res://src/Scenes/General/LineEditMenu/LineEditMenuButton.tscn")

onready var expand_menu : TextureButton = $VBoxContainer/HBoxContainer/ExpandMenu
onready var popup_menu : PopupDialog = $VBoxContainer/PopupMenu
onready var option_vbox : VBoxContainer = $VBoxContainer/PopupMenu/ScrollContainer/VBoxContainer
onready var scroll_container = $VBoxContainer/PopupMenu/ScrollContainer

var _err : int

func _ready():
	#_err = expand_menu.connect("button_down", self, "show_expand_menu", [])
	popup_menu.rect_size = Vector2.ZERO
	_err = expand_menu.connect("button_down", self, "toggle_expand_menu", [])
	_err = popup_menu.connect("visibility_changed", self, "on_popup_menu_visibility_changed", [])


func toggle_expand_menu():
	if popup_menu.get_global_rect().size == Vector2.ZERO:
		emit_signal("menu_to_be_shown")
		popup_menu.popup(get_popup_rect())
	else:
		close_expand_menu()


func on_popup_menu_visibility_changed() -> void:
	# when the popup menu gets hidden by just pressing somewhere
	yield(get_tree(),"idle_frame") # .visible function not set when called normally
	if !popup_menu.visible:
		close_expand_menu()


func close_expand_menu() -> void:
	popup_menu.rect_size = Vector2.ZERO
	popup_menu.rect_position = Vector2.ZERO
	emit_signal("expand_menu_hidden")


func add_static_options(var static_options : PoolStringArray) -> void:
	# adds "static" options which will stay unless specifically deleted
	new_menu_buttons(static_options, false)


func add_temporary_options(var temporary_options : PoolStringArray) -> void:
	# adds options which will then be deleted as soon as the popup closes
	new_menu_buttons(temporary_options, true)


func get_popup_rect() -> Rect2:
	var new_rect : Rect2 = self.get_global_rect()
	new_rect.position.y += self.rect_size.y
	if option_vbox.get_child_count() < 5:
		new_rect.size.y = option_vbox.get_child_count() * 20
	else:
		new_rect.size.y = 200
	return new_rect


func new_menu_buttons(var option_descriptors : PoolStringArray, var is_temporary : bool) -> void:
	var n_button : Button =  null
	for i in option_descriptors.size():
		n_button = menu_button.instance()
		_err = n_button.connect("button_up", self, "emit_signal", ["menu_button_pressed", option_descriptors[i]])
		_err = n_button.connect("button_up", self, "toggle_expand_menu", [])
		if is_temporary:
			_err = self.connect("expand_menu_hidden", n_button, "queue_free")
		option_vbox.add_child(n_button)
		n_button.text = option_descriptors[i]
		n_button.rect_min_size.y = 20
