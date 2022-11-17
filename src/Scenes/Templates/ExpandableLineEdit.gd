extends HBoxContainer

const expandable_line_edit : PackedScene = preload("res://src/scenes/Templates/SingleExpandableLineEdit.tscn")

export var Title : String = "Title"

onready var path_edit_vbox : VBoxContainer = $VBoxContainer
onready var title_label : Label = $Title/Title


func _ready():
	title_label.set_text( Title + ":" )
	add_selection()


func add_selection() -> void:
	var x : HBoxContainer = expandable_line_edit.instance()
	if path_edit_vbox.get_child_count() > 0:
		x.get_node("PlusMinus").set_normal_texture( load("res://src/Assets/Icons/White/General/remove_1_72px.png") )
	path_edit_vbox.add_child( x )
	if x.get_node("PlusMinus").connect("pressed", self, "_on_add_remove_pressed", [ x ] ):
		Global.root.message("CANNOT CONNECT pressed Signal to _on_add_remove_pressed function", SaveData.MESSAGE_ERROR)


func _on_add_remove_pressed(var ref : Node) -> void:
	if ref.get_index() == 0:
		add_selection()
	else:
		path_edit_vbox.remove_child(ref)
		ref.queue_free()
