extends Control

#A Script that is used when displaying different content in a grid that resizes 
#itself according by the window

 

#CONST
const SCROLL_SPEED : int = 45
const PLAYLIST_CONTAINER_LENGTH : int = 170

#NODES
onready var main : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var ContentPlace : Control = $VBoxContainer/HBoxContainer/ScrollContainer/Playlists
onready var PopupBackground : ColorRect = $PlaylistPopups/PopupBackground
onready var PopupPlace : Control = $PlaylistPopups

#VARIABLES
var ContentContainer : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/PlaylistsContainer.tscn")
var PlaylistFromScratch : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/PlaylistFromScratch.tscn")
var PlaylistFromFolder : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistFromFolder.tscn")


func _on_Content_item_rect_changed():
	#Refactor the Playlists on a change of itself's size
	#+10 so the right pixel won't get cut off on edge cases
	var places : int = int(ContentPlace.rect_size.x/(PLAYLIST_CONTAINER_LENGTH + 10))
	ContentPlace.columns = places


func NReady(var ContentArray : Array):
	LoadContent(ContentArray)


func LoadContent(var ContentArray : Array) -> void:
	for n in ContentArray.size():
		var ContentBox : Control = ContentContainer.instance()
		ContentBox.idx = n
		ContentPlace.add_child(ContentBox)
		ContentBox.get_node("HBoxContainer/VBoxContainer/Title").set_text(ContentArray[n])
		ContentBox.find_node("Cover").set_texture(Playlist.GetPlaylistCover(n))
