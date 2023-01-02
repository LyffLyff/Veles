extends "res://src/Scenes/General/StdScrollContainer.gd"

const divided_container_separator : PackedScene = preload("res://src/Scenes/General/DividedContainer/DividedContainerSeparator.tscn")

export (int, 2, 30) var sections : int = 2
export var h_separation : int = 0

var item_counter : int = 0

onready var section_hbox : HBoxContainer = $Sections

func _ready():
	for i in range(sections):
		append_section()
		
		# init headers
		var header : Label = Label.new()
		header.clip_text = true
		section_hbox.get_child(2 * i).add_child(header)
		header.text = "HEADER"


func set_header(var column_idx : int, var title : String) -> void:
	section_hbox.get_child(2 * column_idx).get_child(0).text = title


func get_header(var column_idx : int) -> String:
	return section_hbox.get_child(2 * column_idx).get_child(0).text


func append_section() -> void:
	sections += 1
	var new_section : VBoxContainer = VBoxContainer.new()
	new_section.size_flags_vertical = SIZE_EXPAND_FILL
	new_section.rect_min_size.x = 300
	if section_hbox.get_child_count() != 0:
		section_hbox.add_child(divided_container_separator.instance())
	section_hbox.add_child(new_section)


func append_item(var data : Array) -> void:
	for column_idx in range(0, 2 * sections, 2):
		if 2 * len(data) > column_idx:
			var new_item : Label = get_new_item()
			new_item.text = data[column_idx / 2]
			section_hbox.get_child(column_idx).add_child(new_item)


func get_new_item() -> Label:
	var new_item : Label = Label.new()
	item_counter += 1
	new_item.clip_text = true
	return new_item
