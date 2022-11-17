extends "res://src/Scenes/SubOptions/InfoSettings/OptionTypes/SettingType.gd"


var infos : Dictionary = {
	"Display Name" : 
"""
File Explorer + Extension:
The Name given inside of the File Exlporer including the filetype extension
File Explorer:
The Name give inside of the File Exlporer excluding the filetype extension
Tag Title:
The name the specific file has saved in itself (can be changed inside of Veles -> Change Tag)
""",

"Standard Song Cover" : 
"""
The Path to theImage used as Cover for every song that has no cover embedded.
""",

"Show Songspace Cover" : 
"""
On:
Shows either embedded cover or the standard cover.
This may lead to higher memory and CPU usage (But really not by much)

Off:
Shows nothing where the cover would usually be.
""",

"Image View Background" :
"""
Stars:
Uses starry sky as Background
Standard Color:
Uses the standard color selected under Design Settings -> Image View Standard Background Color, as background color
Auto Color:
Sets the background color of the Image View to a color representing/matching the cover
""",

"Lyrics Text Alignment" : 
"""
Sets the text alignment for Lyrics
""",

"Lyrics Visible Timestamps" : 
"""
Sets the visibility of the Timestamps, when playing synchronized Lyrics
"""
}
