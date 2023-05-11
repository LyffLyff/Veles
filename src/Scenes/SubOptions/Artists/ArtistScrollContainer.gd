# a script that warps the mouses position to the same position on scrolling since
# the ScrollContainers scroll_ended/scroll_started signals ain't working
# and the ScrollContainer does not update the mouse_entered signal on the children
# without a moving the mouse first (temporary fix)
extends "res://src/Scenes/General/StdScrollContainer.gd"


func _ready():
	var _err : int = self.get_v_scrollbar().connect("value_changed", self, "on_scrolling")


func on_scrolling(var _new_val : int) -> void:
	get_tree().get_root().warp_mouse(get_global_mouse_position())
