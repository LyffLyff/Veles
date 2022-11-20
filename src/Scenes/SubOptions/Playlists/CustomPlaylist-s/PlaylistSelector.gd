extends PanelContainer

onready var Playlists : VBoxContainer = $CenterContainer/PanelContainer/ScrollContainer/HBoxContainer/VBoxContainer/Playlists

func _ready():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


func _on_Close_pressed() -> void:
	self.queue_free()
