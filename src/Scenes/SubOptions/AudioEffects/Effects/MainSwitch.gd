extends CheckButton


func _ready():
	Global.connect("audio_effects_toggled", self, "set_pressed")
	on_main_switch_toggled(SongLists.audio_effects.get_main_enabled())


func on_main_switch_toggled(var main_enabled : bool):
	# enabling/disabling the audio effects when the main on/off switch is toggled
	self.set_pressed(main_enabled)
	
	Global.toggle_audio_effects(main_enabled)
