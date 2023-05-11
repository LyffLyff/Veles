extends TextureButton


func on_song_options_pressed() -> void:
	var x : Control = load( "res://src/Scenes/Main/MainSongOptions.tscn" ).instance()
	Global.root.top_ui.add_child(x)
	x.rect_global_position = OS.get_window_size()
	x.rect_global_position.x -= x.rect_size.x
	x.rect_global_position.y -= x.rect_size.y
	x.bottom_buffer.rect_min_size.y = self.rect_size.y
