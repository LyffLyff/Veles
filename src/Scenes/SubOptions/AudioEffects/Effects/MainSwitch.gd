extends CheckButton


func _ready():
	on_main_switch_toggled(
		SongLists.audio_effects[SongLists.audio_effects.size() - 1 ]["main_enabled"]
	)


func on_main_switch_toggled(var main_enabled : bool):
	# enabling/disabling the audio effects when the main on/off switch is toggled
	self.set_pressed( main_enabled )
	
	# only allowing effect to be enabled if main_enabled is true and the effect itself is enabled
	SongLists.audio_effects[SongLists.audio_effects.size() - 1 ]["main_enabled"] = main_enabled
	for i in SongLists.audio_effects.size() - 1:
		AudioServer.set_bus_effect_enabled(0, i, SongLists.audio_effects[i]["enabled"] and main_enabled)
