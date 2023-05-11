extends "res://src/Scenes/SubOptions/InfoSettings/OptionTypes/SettingType.gd"


var infos : Dictionary = {
	"Custom Window Bar" : 
"""
False:
	-uses your OS standard window borders
True:
	-usee a custom made border

!RESTART REQUIRED!
""",
	"Override Title On Playlist Download" : 
"""
True: 
	The given title when downloading a playlist will be overriden by the song title within the playlist.
False:
	The Filename will be the set filename + the title of the song within the playlist
"""
}
