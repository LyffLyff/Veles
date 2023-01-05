extends "res://src/Scenes/General/StdScrollContainer.gd"

const divided_container_separator : PackedScene = preload("res://src/Scenes/General/DividedContainer/DividedContainerSeparator.tscn")

export (int, 0, 30) var sections : int = 0
export var h_separation : int = 0

var item_counter : int = 0

onready var section_hbox : HBoxContainer = $Sections

func _ready():
	init_divided_container()


func init_divided_container() -> void:
	for i in range(sections):
		# init sections
		append_section()


func get_new_item() -> Label:
	var new_item : Label = Label.new()
	item_counter += 1
	new_item.clip_text = true
	return new_item


func set_header(var column_idx : int, var title : String) -> void:
	if 2 * column_idx < section_hbox.get_child_count():
		section_hbox.get_child(2 * column_idx).get_child(0).text = title


func get_header(var column_idx : int) -> String:
	if 2 * column_idx < section_hbox.get_child_count():
		return section_hbox.get_child(2 * column_idx).get_child(0).text
	else:
		return "/"


func set_section() -> void:
	var new_section : VBoxContainer = VBoxContainer.new()
	new_section.size_flags_vertical = SIZE_EXPAND_FILL
	new_section.rect_min_size.x = 300
	if section_hbox.get_child_count() != 0:
		section_hbox.add_child(divided_container_separator.instance())
	section_hbox.add_child(new_section)
	new_section.add_child(Label.new())


func append_section() -> void:
	sections += 1
	set_section()


func append_item(var item_values : PoolStringArray) -> void:
	for column_idx in range(0, 2 * sections, 2):
		if 2 * len(item_values) > column_idx:
			var new_item : Label = get_new_item()
			new_item.text = item_values[column_idx / 2]
			section_hbox.get_child(column_idx).add_child(new_item)


func insert_item(var item_values : PoolStringArray, var idx : int) -> void:
	for column_idx in range(0, 2 * sections, 2):
		if 2 * len(item_values) > column_idx:
			var new_item : Label = get_new_item()
			new_item.text = item_values[column_idx / 2]
			section_hbox.get_child(column_idx).add_child(new_item)
			section_hbox.get_child(column_idx).move_child(new_item, idx)


func clear_items() -> void:
	for column_idx in range(0, 2 * sections, 2):
		for j in range(1, section_hbox.get_child(column_idx).get_child_count()):
			section_hbox.get_child(column_idx).get_child(j).queue_free()


func clear_sections() -> void:
	for child in section_hbox.get_children():
		child.queue_free()
