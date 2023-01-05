extends Control

onready var songs : Control = null

func _ready():
	Global.pressed_playlist_idx = -1
	self.get_child(0).init_playlist()
	var x : SongLoader = SongLoader.new()
	if Global.init_songs:
		x.reload()
		Global.init_songs = false
	songs = self.get_child(0).songs
	x.create_songspaces(songs)
	Global.root.update_highlighted_song(SongLists.current_song)
