class_name AudioEffects extends Reference

var effects : Array = [
	# effect in this Array == Effect idx in AudioBus
	# index 0 in each dictionary saves if the effect is enabled
	{
		"enabled" : false,
		"room_size" : 0.0,
		"damping" : 0.0,
		"spread" : 0.6,
		"hipass" : 0.0,
		"dry" : 0.0,
		"wet" : 1.0,
		"predelay_msec" : 0.0,
		"predelay_feedback" : 0.0,
	},
	{
		"enabled" : false,
		"pan_pullout" : 0.0,
		"time_pullout_ms" : 0.0,
		"surround" : 0.0,
	},
	{
		"enabled" : false,
		"pitch_scale" : 1.0,
	},
	{
		"enabled" : false,
		"cutoff_hz" : 2000.0,
		"resonance" : 0.5,
		"db" : 0.0,
	},
	{
		"enabled" : false,
		"pan" : 0.0
	},
	{
		"enabled" : false,
		"band_db/32_hz" : 0.0,
		"band_db/100_hz" : 0.0,
		"band_db/320_hz" : 0.0,
		"band_db/1000_hz" : 0.0,
		"band_db/3200_hz" : 0.0,
		"band_db/10000_hz" : 0.0
	},
	{
		"enabled" : false,
		"band_db/22_hz" : 0.0,
		"band_db/32_hz" : 0.0,
		"band_db/44_hz" : 0.0,
		"band_db/63_hz" : 0.0,
		"band_db/90_hz" : 0.0,
		"band_db/125_hz" : 0.0,
		"band_db/175_hz" : 0.0,
		"band_db/250_hz" : 0.0,
		"band_db/350_hz" : 0.0,
		"band_db/500_hz" : 0.0,
		"band_db/700_hz" : 0.0,
		"band_db/1000_hz" : 0.0,
		"band_db/1400_hz" : 0.0,
		"band_db/2000_hz" : 0.0,
		"band_db/2800_hz" : 0.0,
		"band_db/4000_hz" : 0.0,
		"band_db/5600_hz" : 0.0,
		"band_db/8000_hz" : 0.0,
		"band_db/11000_hz" : 0.0,
		"band_db/16000_hz"  : 0.0,
		"band_db/22000_hz" : 0.0
	},
	{
		"main_enabled" : false
	}
]


func get_main_enabled() -> bool:
	return effects[effects.size() - 1]["main_enabled"]


func set_main_enabled(var new_main_enabled : bool) -> void:
	effects[effects.size() - 1]["main_enabled"] = new_main_enabled
