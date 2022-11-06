extends "res://src/Scenes/Song/SongOptions/SongOptions.gd"


#NODES
onready var BottomBuffer : Control = $BottomEmpty


func _ready():
	#Background Color
	$PanelContainer.get_stylebox("panel").set_bg_color(
		SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS,"MainSongOptionsBackground")
	)
	
	#Remove From Playlist
	var MainRemoveFromPLaylist : Button = get_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist");
	if MainRemoveFromPLaylist:
		if SongLists.CurrentPlayList >= 0:
			#Only showing option to remove song from playlist, if the song
			#is from a normal playlist
			MainRemoveFromPLaylist.show()
		else:
			MainRemoveFromPLaylist.hide()


func _on_AddToPlaylistMain_pressed():
	_on_AddToPlaylist_pressed(AllSongs.GetMainIdx(SongLists.CurrentSong))


func _on_ChangeTagMain_pressed():
	_on_ChangeTag_pressed(AllSongs.GetMainIdx(SongLists.CurrentSong))


func _on_ShowInFilesystemMain_pressed():
	_on_ShowInFilesystem_pressed(AllSongs.GetMainIdx(SongLists.CurrentSong))


func _on_QueueSongMain_pressed():
	_on_QueueSong_pressed(AllSongs.GetMainIdx(SongLists.CurrentSong))


func _on_RemoveFromPlaylist_pressed():
	RemoveFromPlaylist(AllSongs.GetMainIdx(SongLists.CurrentSong))


func _on_ExtractCurrentCover_pressed():
	ExtractSongCover(AllSongs.GetMainIdx(SongLists.CurrentSong))
