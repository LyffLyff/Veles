extends "res://src/Scenes/Templates/MovableContainers.gd"
# An Option where all artists do have "playlists" with all their songs
# Created on: 25/06/22

onready var header : PanelContainer = $HBoxContainer/ScrollContainer/VBoxContainer/PanelContainer

func _ready():
	MOVABLE_CONTAINER_SEPARATION = movable_container_vbox.get("custom_constants/separation")
	HEADER_HEIGHT = header.rect_size.y
	load_artist_containers("on_artists_selected")


func _enter_tree():
	MOVABLE_CONTAINER_HEIGHT = 80
	scroll = $HBoxContainer/ScrollContainer
	movable_container_vbox = $HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/ArtistSpace
	movable_container_scene = preload("res://src/Scenes/SubOptions/Artists/ArtistSpace.tscn")


func load_artist_containers(var select_method : String) -> void:
	var temp_ref : PanelContainer = null
	var artists : PoolStringArray = []
	for i in SongLists.artists.size():
		temp_ref = movable_container_scene.instance()
		movable_container_vbox.add_child(temp_ref)
		var _err = temp_ref.connect("moving_container_pressed", self, select_method)
		_err = temp_ref.connect("moving_container_held",self,"on_holding_movable_container")
		_err = temp_ref.connect("moving_container_released",self,"on_movable_container_released")
		artists.resize(0)
		artists = SongLists.artists[i]
		temp_ref.init_artist_space( artists, "Producer/Songer/Artist" )


func on_movable_container_released() -> void:
	self.set_process(false)
	movable_container_vbox.set_process(true)
	self.remove_child(movable_container_ref)
	movable_container_vbox.add_child(movable_container_ref)
	movable_container_ref.modulate.a = 1.0
	movable_container_vbox.remove_child(separator_ref)
	separator_ref.queue_free()
	var new_child_idx_f : float = get_new_child_idx_as_float()
	var new_child_idx_i : int = int(new_child_idx_f)
	if false:	# combining artists blocked for a bit
		combine_artists(old_idx,new_child_idx_i)
		movable_container_vbox.get_child(new_child_idx_i).init_artist_space(SongLists.artists[new_child_idx_i],"")
		movable_container_vbox.remove_child(movable_container_ref)
		movable_container_ref.queue_free()
	else:
		movable_container_vbox.move_child(movable_container_ref,new_child_idx_i)
		move_artist_to(old_idx, new_child_idx_i)
	movable_container_ref = null
	separator_ref.queue_free()


func on_artists_selected(var artists : PoolStringArray) -> void:
	SongLists.temporary_playlist_conditions = {
		"includes_either_artist" : [artists]
	}
	
	# passes the title of Playlist -> Main Artists Name
	Global.root.load_temporary_playlist(
		artists.join(", "),
		Global.get_current_user_data_folder() + "/Songs/Artists/Descriptions/" + artists.join("") + ".txt",
		Global.get_current_user_data_folder() + "/Songs/Artists/Covers/" + artists.join("") + ".png",
		3
	)


func move_artist_to(var old_idx : int, var new_idx : int) -> void:
	var artists : PoolStringArray = SongLists.artists[old_idx]
	SongLists.artists.remove(old_idx)
	if new_idx < SongLists.artists.size():
		SongLists.artists.insert(new_idx, artists)
	else:
		SongLists.artists.push_back(artists)


func combine_artists(var old_idx : int, var new_idx : int) -> void:
	var artists : PoolStringArray = SongLists.artists[old_idx]
	SongLists.artists.remove(old_idx)
	SongLists.append_artists(new_idx, artists)
