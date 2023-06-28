extends Control

signal item_selected
signal item_doubleclicked
signal item_options_selected
signal additional_item_selected
signal item_edited
signal exit_item_edit

const divided_container_separator : PackedScene = preload("res://src/Scenes/General/DividedContainer/DividedContainerSeparator.tscn")
const static_highlighter : StyleBox = preload("res://src/Ressources/Themes/DividedContainerStaticHighlighter.tres")
const unhighlighted_item : StyleBoxEmpty = preload("res://src/Ressources/Themes/DivContainerUnhighlightedItem.tres")
const ITEM_HEIGHT : int = 15

export (int, 0, 30) var sections : int = 0
export var h_separation : int = 0
export var v_separation : int = 3

var item_counter : int = 0
var focused_item_idx : int = 0 setget set_focused_item, get_focused_item
var highlighted_item_idx : int = -1
var highlighted_items : PoolIntArray = []
var editable_sections : PoolIntArray = []
var section_callback_functions : PoolStringArray = []
var callback_object : Object = null
var step : int = -1

onready var section_hbox : HBoxContainer = $ScrollContainer/Sections
onready var moving_highlighter : PanelContainer = $MovingHighlighter
onready var scroller : ScrollContainer = $ScrollContainer


func _ready():
	init_divided_container()


func _notification(what):
	if what == NOTIFICATION_WM_FOCUS_OUT or what == NOTIFICATION_WM_MOUSE_EXIT:
		self.set_process(false)
		moving_highlighter.visible = false
	elif what == NOTIFICATION_WM_FOCUS_IN:
		self.set_process(true)


func _unhandled_key_input(event):
	if event.is_pressed():
		match event.scancode:
			KEY_ESCAPE:
				emit_signal("exit_item_edit")


func _process(var _delta : float):
	# set highlighter visibility
	moving_highlighter.visible = scroller.get_global_rect().has_point(get_global_mouse_position()) and Global.active_popups == 0
	if !moving_highlighter.visible:
		return
	# set highlighter position
	moving_highlighter.rect_position.y = get_mouse_item_position()
	moving_highlighter.visible = moving_highlighter.rect_position.y > 0		# skipping the header


func _on_Sections_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			var current_item_idx : int = get_current_idx()
			if current_item_idx > item_counter or current_item_idx == 0:
				# invalid index -> no item there or header (index = 0)
				return
			
			# emits signal with index of pressed item within section list -> -1 skipping the header
			if event.doubleclick:
				match event.button_index:
					BUTTON_LEFT:
						emit_signal("item_doubleclicked", current_item_idx - 1)
			else:
				match event.button_index:
					BUTTON_LEFT:
						if current_item_idx != highlighted_item_idx:
							if !Input.is_key_pressed(KEY_CONTROL):
								free_multiple_higlighted_items()
								emit_signal("item_selected", current_item_idx - 1)
								set_focused_item(current_item_idx)
							else:
								add_highlighted_item(current_item_idx)
					BUTTON_RIGHT:
						emit_signal("item_options_selected", current_item_idx - 1)


func on_editable_item_gui_input(var event : InputEvent, var item_ref : Control) -> void:
	# called when an item that can be edited received a gui input
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.doubleclick and event.button_index == BUTTON_LEFT:
				# double clicked on item that can be edited
				var min_point_x : int = item_ref.get_parent().rect_global_position.x
				var max_point_x : int = min_point_x + item_ref.rect_size.x
				if !scroller.get_global_rect().has_point(Vector2(min_point_x, section_hbox.rect_global_position.y + 20)) or !scroller.get_global_rect().has_point(Vector2(max_point_x, section_hbox.rect_global_position.y + 20)):
					# when the item is cut off on one side -> scroll it to focus
					scroller.set_h_scroll(item_ref.get_parent().rect_position.x)
				
				yield(get_tree(), "idle_frame")
				var line_edit : LineEdit = load("res://src/Scenes/General/DividedContainer/EditableItemLineEdit.tscn").instance()
				Global.root.top_ui.add_child(line_edit)
				line_edit.text = item_ref.get_child(0).text
				line_edit.rect_size.x = item_ref.rect_size.x
				line_edit.grab_focus()
				line_edit.grab_click_focus()
				var section_idx : int = get_section_lists().find(item_ref.get_parent())
				var err : int = line_edit.connect("text_entered", callback_object, section_callback_functions[section_idx], [item_ref.get_index(), section_idx])
				line_edit.connect("item_edit_exit", self, "on_item_edited", [item_ref.get_index(), section_idx])
				self.connect("exit_item_edit", line_edit, "queue_free")
				err = line_edit.connect("text_entered", self, "tagedit_entered", [line_edit, item_ref])
				err = line_edit.connect("focus_exited", line_edit, "queue_free")
				line_edit.rect_global_position = item_ref.rect_global_position
				line_edit.rect_global_position.y -= (line_edit.rect_size.y - item_ref.rect_size.y) / 2
				line_edit.rect_global_position.x -= 1


func toggle_container(var toggle : bool) -> void:
	set_process(toggle)
	set_process_input(toggle)


func tagedit_entered(var n_text : String, var line_edit : LineEdit, var item_ref : PanelContainer) -> void:
	item_ref.get_child(0).text = n_text
	line_edit.queue_free()


func on_item_edited(var new_text : String, var item_idx : int, var section_idx : int) -> void:
	emit_signal("item_edited", item_idx - 1, section_idx, new_text)


func free_multiple_higlighted_items() -> void:
	# unhilights and clear multuiple selected items
	for j in get_section_lists():
		for i in highlighted_items:
			j.get_child(i).set("custom_styles/panel", unhighlighted_item)
	highlighted_items = []


func add_highlighted_item(var item_idx : int) -> void:
	for j in get_section_lists():
		j.get_child(item_idx).set("custom_styles/panel", static_highlighter)
	highlighted_items.push_back(item_idx)
	emit_signal("additional_item_selected", item_idx - 1)


func init_divided_container() -> void:	
	for i in range(sections):
		# init sections
		append_section()
	self.init_highlighter_panels()


func init_highlighter_panels() -> void:
	moving_highlighter.rect_min_size.y = ITEM_HEIGHT
	
	if sections == 0:
		moving_highlighter.visible = false
		step = ITEM_HEIGHT + v_separation
		return

	moving_highlighter.visible = true
	moving_highlighter.rect_position.y = ((ITEM_HEIGHT + v_separation) * focused_item_idx) + ITEM_HEIGHT


func highlight_single_item(var item_idx : int) -> void:
	# highlights the current item and unhighlights the last one
	for i in get_section_lists():
		if highlighted_item_idx in range(0, i.get_child_count()):
			i.get_child(highlighted_item_idx).set("custom_styles/panel", unhighlighted_item)
		i.get_child(item_idx).set("custom_styles/panel", static_highlighter)
	highlighted_item_idx = item_idx


func get_mouse_item_position() -> int:
	# returns the current height of the highlighter where the mouse is located
	return int((get_global_mouse_position().y - scroller.rect_global_position.y) / step) * step - get_scroll_difference()


func get_current_idx() -> int:
	# returns current index in the section lists, header = 0
	if item_counter == 0: 
		return -1
	return int((self.get_global_mouse_position().y - scroller.rect_global_position.y + scroller.get_v_scroll()) / step)


func get_scroll_difference() -> int:
	# returns the offset in which the scrolled sections are of the step of a signle item
	# needed to adjust the moving highlighter when the scroll value is not 0
	return int(stepify(section_hbox.rect_position.y, step) - section_hbox.rect_position.y)


func get_section_lists() -> Array:
	# returns all Vboxes which holds the Labels with the Items values
	# skips all the dividers in between
	var section_lists : Array = []
	for child in section_hbox.get_children():
		if child is VBoxContainer:
			section_lists.push_back(child)
	return section_lists


func set_focused_item(var new_focused_item_idx : int) -> void:
	highlighted_items = [new_focused_item_idx]
	var x = get_section_lists()
	highlight_single_item(new_focused_item_idx)
	focused_item_idx = new_focused_item_idx


func get_focused_item() -> int:
	return focused_item_idx


func get_new_item() -> PanelContainer:
	# returns the formatted label used for items
	var new_item : PanelContainer = load("res://src/Scenes/General/DividedContainer/DivContainerItem.tscn").instance()
	new_item.rect_min_size.y = ITEM_HEIGHT
	new_item.get_child(0).clip_text = true
	new_item.mouse_filter = Control.MOUSE_FILTER_PASS
	return new_item


func get_new_header() -> PanelContainer:
	# returns the formatted label used for headers
	var new_item : PanelContainer = load("res://src/Scenes/General/DividedContainer/DivContainerItem.tscn").instance()
	new_item.get_child(0).set("custom_fonts/font", load("res://src/Ressources/Fonts/NotoSans_SemiBoldItalics_10px.tres"))
	new_item.rect_min_size.y = ITEM_HEIGHT
	new_item.get_child(0).clip_text = false
	return new_item


func set_header(var column_idx : int, var title : String) -> void:
	var section_lists : Array = get_section_lists()
	if column_idx < section_lists.size():
		section_lists[column_idx].get_child(0).get_child(0).text = title


func get_header(var column_idx : int) -> String:
	var section_lists : Array = get_section_lists()
	if column_idx < section_lists.size():
		return section_lists[column_idx].get_child(0).get_child(0).text
	else:
		return "/"


func set_section(var new_section_width  : int) -> void:
	var new_section : VBoxContainer = VBoxContainer.new()
	new_section.mouse_filter = Control.MOUSE_FILTER_PASS
	new_section.rect_clip_content = false
	new_section.size_flags_vertical = SIZE_EXPAND_FILL
	new_section.set("custom_constants/separation", v_separation)
	if new_section_width == 0:
		new_section.set_h_size_flags(SIZE_EXPAND_FILL)
	else:
		new_section.rect_min_size.x = new_section_width
	if section_hbox.get_child_count() != 0:
		section_hbox.add_child(divided_container_separator.instance())
	section_hbox.add_child(new_section)
	new_section.add_child(get_new_header())


func append_section(var is_editable : bool = false, var callback_function : String = "", var section_width : int = 300) -> void:
	if is_editable:
		# push back index of section that has editable items
		editable_sections.push_back(sections)
		section_callback_functions.push_back(callback_function)
	sections += 1
	set_section(section_width)
	init_highlighter_panels()


func append_item(var item_values : PoolStringArray, var editable : bool = false) -> void:
	item_counter += 1
	var section_lists : Array = get_section_lists()
	for column_idx in section_lists.size():
		var new_item : PanelContainer = get_new_item()
		if column_idx in editable_sections:
			var _err = new_item.connect("gui_input", self, "on_editable_item_gui_input", [new_item])
		new_item.get_child(0).text = item_values[column_idx]
		section_lists[column_idx].add_child(new_item)
	
	if item_counter == 1:
		self.set_focused_item(1)


func insert_item(var item_values : PoolStringArray, var idx : int) -> void:
	item_counter += 1
	var section_lists : Array = get_section_lists()
	for column_idx in section_lists.size():
		var new_item : PanelContainer = get_new_item()
		new_item.text = item_values[column_idx]
		section_lists[column_idx].add_child(new_item)
		section_lists[column_idx].move_child(new_item, idx)


func clear_items() -> void:
	# removes all items from all currently existing sections
	item_counter = 0
	var section_lists : Array = get_section_lists()
	for column_idx in section_lists.size():
		# loops through all the items, skips the header
		for item_ref in section_lists[column_idx].get_children():
			if item_ref.get_index() != 0:
				item_ref.queue_free()
				section_lists[column_idx].remove_child(item_ref)


func clear_sections() -> void:
	for child in section_hbox.get_children():
		child.queue_free()


func get_item_values(var item_idx : int) -> PoolStringArray:
	# returns the all the values of a given row
	var values : PoolStringArray = []
	var section_lists : Array = get_section_lists()
	for section_idx in section_lists.size():
		values.push_back(section_lists[section_idx].get_child(item_idx).get_child(0).text)
	return values


func set_item_values(var item_idx : int, var values : PoolStringArray) -> void:
	# the item at the given index to the new values
	var section_lists : Array = get_section_lists()
	for section_idx in section_lists.size():
		section_lists[section_idx].get_child(item_idx).get_child(0).text = values[section_idx]


func get_selected_item_values() -> PoolStringArray:
	return get_item_values(highlighted_item_idx)


func toggle_editable_separators(var toggle : bool) -> void:
	for child in section_hbox.get_children():
		if child is VSeparator:
			child.toggle_movable_separators(toggle)
