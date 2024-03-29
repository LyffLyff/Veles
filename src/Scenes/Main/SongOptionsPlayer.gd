extends TextureButton

var ref : Control = null

func on_song_options_pressed() -> void:
	if !ref:
		ref = load("res://src/Scenes/Main/MainSongOptions.tscn").instance()
		var _err = ref.connect("tree_exited", self, "set_deferred", ["ref", null])
		Global.root.top_ui.add_child(ref)
		ref.rect_global_position = OS.get_window_size()
		ref.rect_global_position.x -= ref.rect_size.x
		ref.rect_global_position.y -= ref.rect_size.y
	else:
		ref.unload_popup()

