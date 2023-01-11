extends Control

onready var song_vbox : Control = null

func _ready():
	Global.pressed_playlist_idx = -1
	self.get_child(0).init_playlist()
	var x : SongLoader = SongLoader.new()
	if Global.init_songs:
		x.reload()
		Global.init_songs = false
	song_vbox = self.get_child(0).song_vbox
	x.create_songspaces(song_vbox)
	Global.root.update_highlighted_song(SongLists.current_song)
