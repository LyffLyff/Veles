extends "res://src/Scenes/General/StdMenuButton.gd"

#Copyright by sampsyo
#https://gist.github.com/sampsyo/1241307
var music_genres : PoolStringArray = []

func _enter_tree():
	load_music_genres()
	menu_button_selections = music_genres


func load_music_genres() -> void:
	var file : File = File.new()
	if file.open("res://src/Scenes/SubOptions/Tagging/music_genres.txt",File.READ) == OK:
		while !file.eof_reached():
			music_genres.push_back( file.get_line() )
