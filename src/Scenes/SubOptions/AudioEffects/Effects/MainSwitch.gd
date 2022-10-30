extends CheckButton


func _ready():
	OnMainSwitchToggled(
		SongLists.AudioEffects[SongLists.AudioEffects.size() - 1 ]["main_enabled"]
	)


func OnMainSwitchToggled(var MainToggleMode : bool):
	self.set_pressed( MainToggleMode )
	SongLists.AudioEffects[SongLists.AudioEffects.size() - 1 ]["main_enabled"] = MainToggleMode
	if MainToggleMode:
		for i in SongLists.AudioEffects.size() - 1:
			if SongLists.AudioEffects[i]["enabled"]:
				AudioServer.set_bus_effect_enabled(0,i,MainToggleMode)
	else:
		for i in SongLists.AudioEffects.size() - 1:
				AudioServer.set_bus_effect_enabled(0,i,MainToggleMode)
