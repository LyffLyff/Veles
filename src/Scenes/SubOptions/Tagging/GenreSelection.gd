extends "res://src/Scenes/General/StdMenuButton.gd"

#Copyright by sampsyo
#https://gist.github.com/sampsyo/1241307
var AllMusicGenres : PoolStringArray = []


func LoadAllMusicGenres() -> void:
	var file : File = File.new()
	if file.open("res://src/Scenes/SubOptions/Tagging/AllMusicGenres.txt",File.READ) == OK:
		while !file.eof_reached():
			AllMusicGenres.push_back( file.get_line() )


func _enter_tree():
	LoadAllMusicGenres()
	MenuButtonSelections = AllMusicGenres
