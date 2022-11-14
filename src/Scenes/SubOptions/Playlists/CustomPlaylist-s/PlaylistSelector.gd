extends PanelContainer


onready var Playlists : VBoxContainer = $CenterContainer/PanelContainer/ScrollContainer/HBoxContainer/VBoxContainer/Playlists
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)


func _ready():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


func OnCloseButtonPressed() -> void:
	self.queue_free()
