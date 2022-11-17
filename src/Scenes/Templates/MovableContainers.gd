extends Control
# Movable Containers

const SCROLL_THRESHOLD : int = 50
const SEPARATOR_HEIGHT : int = 20

var MOVABLE_CONTAINER_HEIGHT : int = -1
var MOVABLE_CONTAINER_SEPARATION : int = -1
var HEADER_HEIGHT : float = -1.0
var movable_container_vbox : VBoxContainer = null
var scroll : ScrollContainer = null
var movable_container_scene : PackedScene = null
var movable_container_ref = null
var old_idx : int = -1
var idx : int = -1
var separator_ref : HSeparator = null
var temp_new_child_idx : float = -1.0


func _enter_tree():
	self.set_process(false)


func _process(_delta):
	if movable_container_ref:
		movable_container_ref.rect_global_position.y = get_global_mouse_position().y - ( MOVABLE_CONTAINER_HEIGHT / 2 )
		if movable_container_ref.rect_global_position.y - SCROLL_THRESHOLD < self.rect_global_position.y:
			scroll.set_v_scroll( scroll.get_v_scroll() - 5 )
		elif movable_container_ref.rect_global_position.y + SCROLL_THRESHOLD > self.rect_size.y:
			scroll.set_v_scroll( scroll.get_v_scroll() + 5 )
		
		temp_new_child_idx = get_new_child_idx_as_float()
		idx = int( temp_new_child_idx )
		if idx >= movable_container_vbox.get_child_count():
			idx = movable_container_vbox.get_child_count() - 1
		separator_ref.show()
		if separator_ref.get_index() != idx:
			movable_container_vbox.move_child(separator_ref,int( temp_new_child_idx ) ) 


func on_holding_movable_container(var child_idx : int) -> void:
	var Ref = movable_container_vbox.get_child(child_idx)
	old_idx = child_idx
	movable_container_ref = Ref
	movable_container_ref.modulate.a = 0.5
	movable_container_vbox.remove_child(movable_container_ref)
	movable_container_vbox.set_process(false)
	self.add_child(movable_container_ref)
	var sep : HSeparator = HSeparator.new()
	separator_ref = sep
	separator_ref.rect_min_size.y = SEPARATOR_HEIGHT
	sep.set_h_size_flags(SIZE_EXPAND_FILL)
	movable_container_vbox.add_child(separator_ref)
	self.set_process(true)


func get_new_child_idx_as_float() -> float:
	var temp : float =  (get_global_mouse_position().y + scroll.get_v_scroll() - HEADER_HEIGHT) / ( MOVABLE_CONTAINER_HEIGHT + MOVABLE_CONTAINER_SEPARATION)
	if temp >= movable_container_vbox.get_child_count():
		temp =  movable_container_vbox.get_child_count() - 1
	elif temp < 0:
		temp = 0
	return temp


func check_combine_threshold(var index_as_float : float) -> bool:
	var fraction_digits : float = index_as_float - int(index_as_float) #- 0.5
	fraction_digits = abs(fraction_digits)
	return ( fraction_digits > 0.65 and fraction_digits < 1.0 )


