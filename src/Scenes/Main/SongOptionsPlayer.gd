extends TextureButton


var ref : Control = null


func OnDisplayOptionsPressed() -> void:
	if !ref:
		ref = load( "res://src/scenes/Main/MainSongOptions.tscn" ).instance()
		var _err = ref.connect("tree_exited",self,"set",["ref",null])
		Global.root.TopUI.add_child(ref)
		ref.rect_global_position = OS.get_window_size()
		ref.rect_global_position.x -= ref.rect_size.x
		ref.rect_global_position.y -= ref.rect_size.y
	else:
		ref.ExitPlayerOption()

