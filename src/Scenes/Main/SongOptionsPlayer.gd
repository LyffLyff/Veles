extends TextureButton


func OnDisplayOptionsPressed() -> void:
	var x : Control = load( "res://src/scenes/Main/MainSongOptions.tscn" ).instance()
	Global.root.TopUI.add_child(x)
	x.rect_global_position = OS.get_window_size()
	x.rect_global_position.x -= x.rect_size.x
	x.rect_global_position.y -= x.rect_size.y

