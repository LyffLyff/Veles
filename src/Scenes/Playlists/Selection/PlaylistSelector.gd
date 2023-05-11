extends "res://src/Scenes/General/StdPopupBackground.gd"

onready var playlists : VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/HBoxContainer/VBoxContainer/Playlists

func _on_Close_pressed() -> void:
	self.exit_popup()


func init_selector(var main_idxs : PoolIntArray) -> void:
	for n in SongLists.normal_playlists.size():
		var x : Button = Button.new()
		x.rect_min_size.y = 25
		self.playlists.add_child(x)
		if x.connect("pressed", Global, "add_to_playlist", [self, n, main_idxs]):
			Global.message("ADDING SONG TO PLAYLIST", Enumerations.MESSAGE_ERROR, true)
		x.text = SongLists.normal_playlists.keys()[n]
	
	# Show Message when there are no normal playlists
	if SongLists.normal_playlists.size() == 0:
		var label : Label = Label.new()
		label.size_flags_vertical = SIZE_EXPAND_FILL
		self.playlists.add_child(label)
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
		label.text = "There are no Playlists :( , go to the 'Playlists' subsection to create one"
