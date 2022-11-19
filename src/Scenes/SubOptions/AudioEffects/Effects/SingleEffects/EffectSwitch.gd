extends CheckButton

var effect_idx : int = -1

func init_effect_switch() -> void:
	on_effect_toggled( SongLists.audio_effects[effect_idx].values()[0] )


func on_effect_toggled(var toggle : bool) -> void:
	var main_enabled : bool = SongLists.audio_effects[SongLists.audio_effects.size() - 1 ]["main_enabled"]
	self.set_pressed( toggle )
	SongLists.audio_effects[effect_idx]["enabled"] = toggle
	if main_enabled:
		AudioServer.set_bus_effect_enabled(0, effect_idx, toggle)
