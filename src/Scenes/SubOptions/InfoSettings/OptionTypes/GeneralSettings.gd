extends "res://src/Scenes/SubOptions/InfoSettings/OptionTypes/SettingType.gd"


var infos : Dictionary = {
	"Transparent Background" : 
"""
On:
The Background of this application is transparent.
May cause higher more system ressources!!

Off:
The Background is NOT Transparent in any way, uses less system ressources, especially regarding GPU

!RESTART REQUIRED!
""",

	"Custom Window Bar" : 
"""
False:
	-uses your OS standard window borders
True:
	-usee a custom made border

!RESTART REQUIRED!
"""
}
