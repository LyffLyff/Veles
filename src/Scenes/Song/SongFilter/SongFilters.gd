extends Control


#SIGNALS
signal filter_status


#NODES
onready var line_edit : LineEdit = $HBoxContainer/VBoxContainer/Panel/HBoxContainer/Filter


func _enter_tree():
	self.set_process(false)


func _process(var _delta : float):
	if !self.get_global_rect().has_point( get_global_mouse_position() ):
		line_edit.release_focus()
		self.set_process(false)


func _on_Filter_text_entered(new_text):
	line_edit.release_focus()
	var songs : VBoxContainer = get_owner().songs
	if new_text != "":
		emit_signal("filter_status",true)
		for n in songs.get_child_count():
			var song_name : String = AllSongs.GetSongTitle( songs.get_child(n).main_index )
			# if the text is somewhat similar or includes the entered phrase it'll be shown
			if song_name.similarity(new_text) > 0.7 or song_name.findn(new_text,0) != -1:
				#if Global.valid_song(song_name) == 1 or  Global.valid_song(song_name) == 0:			#onyl allows valid files to be shown -> else can show .wav files
				songs.get_child(n).show()
			else:
				songs.get_child(n).hide()
	else:
		emit_signal("filter_status",false)
		for n in songs.get_child_count():
			songs.get_child(n).show()


func _on_Filter_focus_entered():
	self.set_process(true)
	$AnimationPlayer.play("Fade")


func _on_Filter_focus_exited():
	$AnimationPlayer.play_backwards("Fade")
