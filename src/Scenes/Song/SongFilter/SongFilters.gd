extends Control
# script that handles the songfilter
# it receives a text input with a line edit
# it then checks through every song and only makes those visible
# that fit the phrase or are similaar to a certain degree

signal is_filtering

const Y_THRESHOLD : int = 240

onready var filter_edit : LineEdit = $MarginContainer/PanelContainer/Filter
onready var background : PanelContainer = $MarginContainer/PanelContainer


func _enter_tree():
	self.set_process(false)


func _input(event):
	# delete on any mouse input outside of lineedit
	if event is InputEventMouseButton and event.pressed and !self.get_global_rect().has_point(get_global_mouse_position()):
		filter_edit.release_focus()
		self.set_process(false)


func _on_Filter_text_entered(var filter_phrase : String):
	filter_edit.release_focus()
	apply_filter(filter_phrase)


func _on_Filter_text_changed(var filter_phrase : String):
	apply_filter(filter_phrase)


func _on_Filter_focus_entered():
	self.set_process(true)
	modulate_background(0.4)


func _on_Filter_focus_exited():
	modulate_background(0.0)


func apply_filter(var filter_phrase : String) -> void:
	var song_vbox : VBoxContainer = get_owner().song_vbox
	if filter_phrase != "":
		emit_signal("is_filtering",true)
		get_owner().song_vbox.set_filter_status(true)
		for n in song_vbox.get_child_count():
			var song_name : String = AllSongs.get_song_filename(song_vbox.get_child(n).main_index)
			# if the text is somewhat similar or includes the entered phrase it'll be shown
			if song_name.similarity(filter_phrase) > 0.7 or song_name.findn(filter_phrase,0) != -1:
				# if Global.valid_song(song_name) == 1 or  Global.valid_song(song_name) == 0:			#onyl allows valid files to be shown -> else can show .wav files
				song_vbox.get_child(n).show()
			else:
				song_vbox.get_child(n).hide()
	else:
		get_owner().song_vbox.set_filter_status(false)
		emit_signal("is_filtering",false)
		for n in song_vbox.get_child_count():
			song_vbox.get_child(n).show()


func modulate_background(var final_val : float) -> void:
	var _tw = create_tween().tween_property(
		background,
		"self_modulate:a",
		final_val,
		0.2
	)
