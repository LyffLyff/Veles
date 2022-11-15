#An Option where all artists do have "playlists" with all their songs
#Created on: 25/06/22

extends "res://src/Scenes/Templates/MovableContainers.gd"

#NODES
onready var Header : PanelContainer = $HBoxContainer/ScrollContainer/VBoxContainer/PanelContainer



func _enter_tree():
	MOVABLE_CONTAINER_HEIGHT = 80
	Scroll = $HBoxContainer/ScrollContainer
	MovableContainerVBox = $HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/ArtistSpace
	MovableContainerScene = preload("res://src/Scenes/SubOptions/Artists/ArtistSpace.tscn")


func _ready():
	MOVABLE_CONTAINER_SEPARATION = MovableContainerVBox.get("custom_constants/separation")
	HEADER_HEIGHT = Header.rect_size.y
	LoadArtistContainers("OnArtistSelected")


func LoadArtistContainers(var SelectMethod : String) -> void:
	var x : PanelContainer = null
	var artists : PoolStringArray = []
	for i in SongLists.artists.size():
		x = MovableContainerScene.instance()
		MovableContainerVBox.add_child( x )
		var _err = x.connect("MovingContainerPressed", self, SelectMethod)
		_err = x.connect("HoldingMovableContainer",self,"OnHoldingMovableContainer")
		_err = x.connect("ReleasedMovableContainer",self,"OnMovableContainerReleased")
		artists.resize(0)
		artists = SongLists.artists[i]
		x.InitArtistSpace( artists, "Producer/Songer/Artist" )


func OnMovableContainerReleased() -> void:
	self.set_process(false)
	MovableContainerVBox.set_process(true)
	self.remove_child(MovableContainerRef)
	MovableContainerVBox.add_child(MovableContainerRef)
	MovableContainerRef.modulate.a = 1.0
	MovableContainerVBox.remove_child(SeparatorRef)
	SeparatorRef.queue_free()
	var NewChildIdxF : float = GetNewChildIdxAsFloat()
	var NewChildIdxI : int = int(NewChildIdxF)
	if false:	#Combining artists blocked for a bit
		CombineArtists(OldIdx,NewChildIdxI)
		MovableContainerVBox.get_child(NewChildIdxI).InitArtistSpace(SongLists.artists[NewChildIdxI],"")
		MovableContainerVBox.remove_child(MovableContainerRef)
		MovableContainerRef.queue_free()
	else:
		MovableContainerVBox.move_child(MovableContainerRef,NewChildIdxI)
		MoveArtistFrom(OldIdx,NewChildIdxI)
	MovableContainerRef = null
	SeparatorRef.queue_free()


func OnArtistSelected(var ArtistNames : PoolStringArray) -> void:
	SongLists.temporary_playlist_conditions = {
		"includes_either_artist" : [ArtistNames]
	}
	
	#Passes the Title of Playlist -> Main Artists Name
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
