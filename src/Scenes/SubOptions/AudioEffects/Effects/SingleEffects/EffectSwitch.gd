extends CheckButton


#VARIABLES
var EffectIdx : int = -1


func InitEffectSwitch() -> void:
	OnEffectToggled( SongLists.AudioEffects[EffectIdx].values()[0] )


func OnEffectToggled(var ToggleMode : bool) -> void:
	var MainEnabled : bool = SongLists.AudioEffects[SongLists.AudioEffects.size() - 1 ]["main_enabled"]
	self.set_pressed( ToggleMode )
	if AudioServer.is_bus_effect_enabled(0, EffectIdx) != ToggleMode:
		SongLists.AudioEffects[EffectIdx]["enabled"] = ToggleMode
		if MainEnabled:
			AudioServer.set_bus_effect_enabled(0, EffectIdx, ToggleMode)
