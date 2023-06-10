extends VBoxContainer

const item : PackedScene = preload("res://src/Scenes/Templates/SingleExpandableLineEdit.tscn")

export var header_text : String = "Header"

onready var top_item : HBoxContainer = $List/TopItem
onready var list : VBoxContainer = $List
onready var header : Label = $Header

var additional_item_counter : int = 0	# counts the items apart from the main / top item

func _ready():
	header.text = header_text
	top_item.connect("add_pressed",  self, "append_item")


func get_items() -> PoolStringArray:
	var item_values : PoolStringArray = []
	for child in list.get_children():
		item_values.push_back(child.line_edit.text)
	return item_values


func set_items(var item_values : PoolStringArray) -> void:
	clear_items()
	for i in item_values.size():
		if i == 0:
			top_item.line_edit.text = item_values[i]
		else:
			append_item(item_values[i])


func append_item(var init_value : String = "") -> void:
	additional_item_counter += 1
	var new_item : Control = item.instance()
	list.add_child(new_item)
	new_item.line_edit.text = init_value
	var _err : int = new_item.connect("remove_pressed", self, "remove_item")


func clear_items() -> void:
	for child in list.get_children():
		if child.get_index() != 0:
			list.remove_child(child)
			child.queue_free()


func remove_item(var child_idx : int) -> void:
	additional_item_counter -= 1
	list.get_child(child_idx).queue_free()
