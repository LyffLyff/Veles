extends "res://src/Scenes/Templates/MovableContainers.gd"
# An Option where all artists do have "playlists" with all their songs
# Created on: 25/06/22

onready var Header : PanelContainer = $HBoxContainer/ScrollContainer/VBoxContainer/PanelContainer


func _ready():
	MOVABLE_CONTAINER_SEPARATION = movable_container_vbox.get("custom_constants/separation")
	HEADER_HEIGHT = Header.rect_size.y
	LoadArtistContainers("OnArtistSelected")


func _enter_tree():
	MOVABLE_CONTAINER_HEIGHT = 80
	scroll = $HBoxContainer/ScrollContainer
	movable_container_vbox = $HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/ArtistSpace
	movable_container_scene = preload("res://src/Scenes/SubOptions/Artists/ArtistSpace.tscn")


func LoadArtistContainers(var SelectMethod : String) -> void:
	var x : PanelContainer = null
	var artists : PoolStringArray = []
	for i in SongLists.artists.size():
		x = movable_container_scene.instance()
		movable_container_vbox.add_child( x )
		var _err = x.connect("moving_container_pressed", self, SelectMethod)
		_err = x.connect("moving_container_held",self,"on_holding_movable_container")
		_err = x.connect("moving_container_released",self,"OnMovableContainerReleased")
		artists.resize(0)
		artists = SongLists.artists[i]
		x.InitArtistSpace( artists, "Producer/Songer/Artist" )


func OnMovableContainerReleased() -> void:
	self.set_process(false)
	movable_container_vbox.set_process(true)
	self.remove_child(movable_container_ref)
	movable_container_vbox.add_child(movable_container_ref)
	movable_container_ref.modulate.a = 1.0
	movable_container_vbox.remove_child(separator_ref)
	separator_ref.queue_free()
	var NewChildIdxF : float = get_new_child_idx_as_float()
	var NewChildIdxI : int = int(NewChildIdxF)
	if false:	#Combining artists blocked for a bit
		CombineArtists(old_idx,NewChildIdxI)
		movable_container_vbox.get_child(NewChildIdxI).InitArtistSpace(SongLists.artists[NewChildIdxI],"")
		movable_container_vbox.remove_child(movable_container_ref)
		movable_container_ref.queue_free()
	else:
		movable_container_vbox.move_child(movable_container_ref,NewChildIdxI)
		MoveArtistFrom(old_idx,NewChildIdxI)
	movable_container_ref = null
	separator_ref.queue_free()


func OnArtistSelected(var ArtistNames : PoolStringArray) -> void:
	SongLists.temporary_playlist_conditions = {
		"includes_either_artist" : [ArtistNames]
	}
	
	# passes the Title of Playlist -> Main Artists Name
	Global.root.load_temporary_playlist(
		ArtistNames.join(", "),
		Global.get_current_user_data_folder() + "/Songs/Artists/Descriptions/" + ArtistNames.join("") + ".txt",
		Global.get_current_user_data_folder() + "/Songs/Artists/Covers/" + ArtistNames.join("") + ".png",
		3
	)


func MoveArtistFrom(var OldArtistIdx : int, var NewIdx : int) -> void:
	var artists : PoolStringArray = SongLists.artists[OldArtistIdx]
	SongLists.artists.remove(OldArtistIdx)
	if NewIdx < SongLists.artists.size():
		SongLists.artists.insert(NewIdx,artists)
	else:
		SongLists.artists.push_back(artists)


func CombineArtists(var OldArtistIdx : int, var NewIdx : int) -> void:
	var artists : PoolStringArray = SongLists.artists[OldArtistIdx]
	SongLists.artists.remove(OldArtistIdx)
	SongLists.append_artists(NewIdx, artists)
