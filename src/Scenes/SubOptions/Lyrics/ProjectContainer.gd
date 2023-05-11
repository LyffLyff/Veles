extends Button
# container for opened .vpl projects

onready var icon_texture : TextureRect = $HBoxContainer/Icon
onready var date : Label = $HBoxContainer/Date
onready var file : Label = $HBoxContainer/VBoxContainer/File
onready var path : Label = $HBoxContainer/VBoxContainer/Path
