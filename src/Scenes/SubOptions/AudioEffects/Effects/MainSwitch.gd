extends CheckButton


func _ready():
	OnMainSwitchToggled(
		SongLists.audio_effects[SongLists.audio_effects.size() - 1 ]["main_enabled"]
	)


func OnMainSwitchToggled(var MainToggleMode : bool):
	self.set_pressed( MainToggleMode )
	SongLists.audio_effects[SongLists.audio_effects.size() - 1 ]["main_enabled"] = MainToggleMode
	if MainToggleMode:
		for i in SongLists.audio_effects.size() - 1:
			if SongLists.audio_effects[i]["enabled"]:
				AudioServer.set_bus_effect_enabled(0,i,MainToggleMode)
	else:
		for i in SongLists.audio_effects.size() - 1:
				AudioServer.set_bus_effect_enabled(0,i,MainToggleMode)
