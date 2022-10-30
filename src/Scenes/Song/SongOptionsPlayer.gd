extends TextureButton

#NODES
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)


func OnDisplayOptionsPressed() -> void:
	var x : Control = load( "res://src/scenes/Main/MainSongOptions.tscn" ).instance()
	root.TopUI.add_child(x)
	x.rect_global_position = OS.get_window_size()
	x.rect_global_position.x -= x.rect_size.x
	x.rect_global_position.y -= x.rect_size.y
	x.BottomBuffer.rect_min_size.y = self.rect_size.y
