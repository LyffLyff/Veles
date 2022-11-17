extends CheckButton

var EffectIdx : int = -1

func InitEffectSwitch() -> void:
	OnEffectToggled( SongLists.audio_effects[EffectIdx].values()[0] )


func OnEffectToggled(var toggle : bool) -> void:
	var main_enabled : bool = SongLists.audio_effects[SongLists.audio_effects.size() - 1 ]["main_enabled"]
	self.set_pressed( toggle )
	SongLists.audio_effects[EffectIdx]["enabled"] = toggle
	if main_enabled:
		AudioServer.set_bus_effect_enabled(0, EffectIdx, toggle)
