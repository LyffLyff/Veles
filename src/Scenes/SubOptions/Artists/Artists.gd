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
	var Artists : PoolStringArray = []
	for i in SongLists.Artists.size():
		x = MovableContainerScene.instance()
		MovableContainerVBox.add_child( x )
		var _err = x.connect("MovingContainerPressed", self, SelectMethod)
		_err = x.connect("HoldingMovableContainer",self,"OnHoldingMovableContainer")
		_err = x.connect("ReleasedMovableContainer",self,"OnMovableContainerReleased")
		Artists.resize(0)
		Artists = SongLists.Artists[i]
		x.InitArtistSpace( Artists, "Producer/Songer/Artist" )


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
		MovableContainerVBox.get_child(NewChildIdxI).InitArtistSpace(SongLists.Artists[NewChildIdxI],"")
		MovableContainerVBox.remove_child(MovableContainerRef)
		MovableContainerRef.queue_free()
	else:
		MovableContainerVBox.move_child(MovableContainerRef,NewChildIdxI)
		MoveArtistFrom(OldIdx,NewChildIdxI)
	MovableContainerRef = null
	SeparatorRef.queue_free()


func OnArtistSelected(var ArtistNames : PoolStringArray) -> void:
	SongLists.TempPlaylistConditions = {
		"IncludesEitherArtist" : [ArtistNames]
	}
	
	#Passes the Title of Playlist -> Main Artists Name
	Global.root.LoadTemporaryPlaylist(
		ArtistNames.join(", "),
		Global.GetCurrentUserDataFolder() + "/Songs/Artists/Descriptions/" + ArtistNames.join("") + ".txt",
		Global.GetCurrentUserDataFolder() + "/Songs/Artists/Covers/" + ArtistNames.join("") + ".png",
		3
	)


func MoveArtistFrom(var OldArtistIdx : int, var NewIdx : int) -> void:
	var Artists : PoolStringArray = SongLists.Artists[OldArtistIdx]
	SongLists.Artists.remove(OldArtistIdx)
	if NewIdx < SongLists.Artists.size():
		SongLists.Artists.insert(NewIdx,Artists)
	else:
		SongLists.Artists.push_back(Artists)


func CombineArtists(var OldArtistIdx : int, var NewIdx : int) -> void:
	var Artists : PoolStringArray = SongLists.Artists[OldArtistIdx]
	SongLists.Artists.remove(OldArtistIdx)
	SongLists.AppendArtists(NewIdx, Artists)
