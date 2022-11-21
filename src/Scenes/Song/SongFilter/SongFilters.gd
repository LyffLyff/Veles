extends Control
# script that handles the songfilter
# it receives a text input with a line edit
# it then checks through every song and only makes those visible
# that fit the phrase or are similaar to a certain degree

signal is_filtering

const HOLD_THRESHOLD : int = 120

onready var filter_edit : LineEdit = $VBoxContainer/Panel/HBoxContainer/Filter
onready var background : Panel = $VBoxContainer/Panel


func _enter_tree():
	self.set_process(false)


func _process(var _delta : float):
	# checking if the global mouse position is below a max threshold below the filter edit
	if get_global_mouse_position().y - HOLD_THRESHOLD > self.get_global_position().y:
		filter_edit.release_focus()
		self.set_process(false)


func _on_Filter_text_entered(var filter_phrase : String):
	filter_edit.release_focus()
	apply_filter(filter_phrase)


func _on_Filter_text_changed(var filter_phrase : String):
	apply_filter(filter_phrase)


func _on_Filter_focus_entered():
	self.set_process(true)
	modulate_background(0.5)


func _on_Filter_focus_exited():
	modulate_background(0.0)


func apply_filter(var filter_phrase : String) -> void:
	var songs : VBoxContainer = get_owner().songs
	if filter_phrase != "":
		emit_signal("is_filtering",true)
		for n in songs.get_child_count():
			var song_name : String = AllSongs.get_song_filename( songs.get_child(n).main_index )
			# if the text is somewhat similar or includes the entered phrase it'll be shown
			if song_name.similarity(filter_phrase) > 0.7 or song_name.findn(filter_phrase,0) != -1:
				# if Global.valid_song(song_name) == 1 or  Global.valid_song(song_name) == 0:			#onyl allows valid files to be shown -> else can show .wav files
				songs.get_child(n).show()
			else:
				songs.get_child(n).hide()
	else:
		emit_signal("is_filtering",false)
		for n in songs.get_child_count():
			songs.get_child(n).show()


func modulate_background(var final_val : float) -> void:
	var _tw = create_tween().tween_property(
		background,
		"self_modulate:a",
		final_val,
		0.2
	)
