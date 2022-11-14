extends Control
# a Script that is used when displaying different content in a grid that resizes 
# itself according by the window

const SCROLL_SPEED : int = 45
const PLAYLIST_CONTAINER_LENGTH : int = 170

const CONTENT_CONTAINER : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/PlaylistsContainer.tscn")
const PLAYLIST_FROM_SCRATCH : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/PlaylistFromScratch.tscn")
const PLAYLIST_FROM_FOLDER : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistFromFolder.tscn")

onready var main : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var content_place : Control = $VBoxContainer/HBoxContainer/ScrollContainer/Playlists


func n_ready(var ContentArray : Array):
	load_content(ContentArray)


func _on_Content_item_rect_changed():
	# refactor the Playlists on a change of itself's size
	# +10 so the right pixel won't get cut off on edge cases
	var places : int = int(content_place.rect_size.x/(PLAYLIST_CONTAINER_LENGTH + 10))
	content_place.columns = places


func load_content(var content : Array) -> void:
	for n in content.size():
		var content_box : Control = CONTENT_CONTAINER.instance()
		content_box.idx = n
		content_place.add_child(content_box)
		content_box.get_node("HBoxContainer/VBoxContainer/Title").set_text(content[n])
		content_box.find_node("Cover").set_texture(Playlist.get_playlist_cover(n))
