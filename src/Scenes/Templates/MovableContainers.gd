extends Control


#CONSTANTS
const SCROLL_THRESHOLD : int = 50
const SEPARATOR_HEIGHT : int = 20

#NODES
var MovableContainerVBox : VBoxContainer = null
var Scroll : ScrollContainer = null

#VARIABLES
var MovableContainerScene : PackedScene = null
var MovableContainerRef = null
var OldIdx : int = -1
var idx : int = -1
var SeparatorRef : HSeparator = null
var TempNewChildIdx : float = -1.0
var MOVABLE_CONTAINER_HEIGHT : int = -1
var MOVABLE_CONTAINER_SEPARATION : int = -1
var HEADER_HEIGHT : float = -1.0


func _enter_tree():
	self.set_process(false)


func _process(_delta):
	if MovableContainerRef:
		MovableContainerRef.rect_global_position.y = get_global_mouse_position().y - ( MOVABLE_CONTAINER_HEIGHT / 2 )
		if MovableContainerRef.rect_global_position.y - SCROLL_THRESHOLD < self.rect_global_position.y:
			Scroll.set_v_scroll( Scroll.get_v_scroll() - 5 )
		elif MovableContainerRef.rect_global_position.y + SCROLL_THRESHOLD > self.rect_size.y:
			Scroll.set_v_scroll( Scroll.get_v_scroll() + 5 )
		
		TempNewChildIdx = GetNewChildIdxAsFloat()
		idx = int( TempNewChildIdx )
		if idx >= MovableContainerVBox.get_child_count():
			idx = MovableContainerVBox.get_child_count() - 1
		SeparatorRef.show()
		if SeparatorRef.get_index() != idx:
			MovableContainerVBox.move_child(SeparatorRef,int( TempNewChildIdx ) ) 


func OnHoldingMovableContainer(var ChildIdx : int) -> void:
	var Ref = MovableContainerVBox.get_child(ChildIdx)
	OldIdx = ChildIdx
	MovableContainerRef = Ref
	MovableContainerRef.modulate.a = 0.5
	MovableContainerVBox.remove_child(MovableContainerRef)
	MovableContainerVBox.set_process(false)
	self.add_child(MovableContainerRef)
	var sep : HSeparator = HSeparator.new()
	SeparatorRef = sep
	SeparatorRef.rect_min_size.y = SEPARATOR_HEIGHT
	sep.set_h_size_flags(SIZE_EXPAND_FILL)
	MovableContainerVBox.add_child(SeparatorRef)
	self.set_process(true)


func GetNewChildIdxAsFloat() -> float:
	var temp : float =  (get_global_mouse_position().y + Scroll.get_v_scroll() - HEADER_HEIGHT) / ( MOVABLE_CONTAINER_HEIGHT + MOVABLE_CONTAINER_SEPARATION)
	if temp >= MovableContainerVBox.get_child_count():
		temp =  MovableContainerVBox.get_child_count() - 1
	elif temp < 0:
		temp = 0
	return temp


func CheckCombineThreshold(var IndexAsFloat : float) -> bool:
	var FractionDigits : float = IndexAsFloat - int(IndexAsFloat) #- 0.5
	FractionDigits = abs(FractionDigits)
	return ( FractionDigits > 0.65 and FractionDigits < 1.0 )


