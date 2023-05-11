extends Control

var idx : int = -1

onready var title : Label = $MarginContainer/VBoxContainer/Title
onready var cover : TextureRect = $MarginContainer/VBoxContainer/Cover

func _on_Playlist_pressed():
	Global.pressed_playlist_idx = idx
	Global.root.load_playlist(idx)


func init_playlist_container(var playlist_title : String, var cover_texture : Texture) -> void:
	title.set_deferred("text", playlist_title)
	# waiting for next frame so the covers rect_size updated with the changed text
	cover.texture = ImageLoader.resize_texture(
		cover_texture,
		Vector2(cover.rect_size.y,cover.rect_size.y)
	)
