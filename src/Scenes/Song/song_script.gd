extends Control


onready var cover : TextureRect = $Panel/HBoxContainer/Cover

#saves the index of the song inside of AllSongs
var main_index : int = 0

#saves the index of the Playlist used in SongLists CurrentPlaylist
var playlist_idx : int = -1


var path : String = ""
