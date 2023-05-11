extends HBoxContainer

onready var empty_cover : Control = $EmptyCover

func _ready():
	empty_cover.visible = SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ShowSongspaceCover")
