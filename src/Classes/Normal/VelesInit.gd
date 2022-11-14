class_name VelesInit extends Reference
# class that holds function, that will only be used at startup or at the switch of the current user
# this script loads and saves user specific settings/values

func init_random_settings() -> void:
	# init Config
	var config : ConfigFile = SaveData.load_config_file("user://override.cfg")
	var property_path : String
	var config_val = null
	for config_section in config.get_sections():
		for section_key in config.get_section_keys(config_section):
			property_path = config_section + "/" + section_key
			config_val = SaveData.get_config_value(config_section, section_key)
			if !ProjectSettings.has_setting(property_path):
				continue;
			if ProjectSettings.get_setting(property_path) != config_val:
				ProjectSettings.set_setting(property_path, config_val )
	#var _err = ProjectSettings.save()
	
	# init Random
	if AudioServer.get_device_list().has(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "AudioOutputDevice")):
		AudioServer.set_device( SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "AudioOutputDevice") )
	else:
		# if the Saved Audio Output Device cannot be found anymore
		# the default will be selected 
		AudioServer.set_device("Default")
	ProjectSettings.set_setting("rendering/environment/default_clear_color",Color("c52a2a2a"))


func create_folders():
	var dir : Directory = Directory.new()
	if dir.open("user://") == OK:
		# the folders inside this string array will be created if they not already exist 
		
		# global folders
		var global_folders : PoolStringArray = [
			"GlobalSettings",
			"GlobalSettings/UserImages",
			"GlobalSettings/StdUserdata",
			"GlobalSettings/ExportTemplates",
			"GlobalSettings/AppStats"
		]
		for n in global_folders.size():
			if !dir.dir_exists(global_folders[n]):
				if dir.make_dir_recursive(global_folders[n]) != OK:
					Global.root.message("CREATING" + global_folders[n] + "FOLDER",SaveData.MESSAGE_ERROR)
		
		# user Specific folders
		var user_specific_folders : PoolStringArray = [
			"Settings",
			"Settings/CoreSettings",
			"Settings/StdCovers",
			"Settings/AudioEffects",
			"Settings/AudioEffects/Presets",
			"Songs",
			"Lyrics",
			"Lyrics/Projects",
			"Downloads",
			"Songs/Playlists",
			"Songs/Playlists/SmartPlaylists",
			"Songs/Playlists/SmartPlaylists/Conditions",
			"Songs/Playlists/NormalPlaylists",
			"Songs/Playlists/Metadata",
			"Songs/Playlists/Metadata/Descriptions",
			"Songs/Playlists/Covers",
			"Songs/Streams/DailyStreams",
			"Songs/Streams",
			"Songs/AllSongs",
			"Songs/AllSongs/Covers",
			"Songs/Artists",
			"Songs/Artists/Descriptions",
			"Songs/Artists/Covers",
			"Songs/Artists/Names"
		]
		for username in Global.UserProfiles:
			for n in user_specific_folders.size():
				if !dir.dir_exists(Global.GetCurrentUserDataFolder() + user_specific_folders[n]):
					if dir.make_dir_recursive("Users/" + username  + "/" + user_specific_folders[n]) != OK:
						Global.root.message("CREATING" + user_specific_folders[n] + "FOLDER",SaveData.MESSAGE_ERROR)


func init_audio_effects() -> void:
	var main_enabled : bool = SongLists.AudioEffects[SongLists.AudioEffects.size() - 1]["main_enabled"]
	for i in SongLists.AudioEffects.size() - 1:
		# setting Effect Enabled
		# if main is not enabled the effects will be set to off no matter what
		AudioServer.set_bus_effect_enabled(
			0,
			i,
			SongLists.AudioEffects[i]["enabled"] and main_enabled
		)
		
		# setting Effect Values
		var x : AudioEffect = AudioServer.get_bus_effect(0,i)
		for j in range(1, SongLists.AudioEffects[i].size()):
			x.set_deferred( SongLists.AudioEffects[i].keys()[j], SongLists.AudioEffects[i].values()[j] )


func init_volume() -> void:
	MainStream.set_volume(
		db2linear(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "Volume"))
	)


func copy_std_audio_presets() -> void:
	# copying Standard Presets from project to userdata, on first time
	if !Directory.new().file_exists( SongLists.AddUserToFilepath( SongLists.FilePaths[17] ) ):
		var dir : Directory = Directory.new()
		if dir.open("res://src/Ressources/StdAudioPresets") == OK:
			if dir.list_dir_begin(true,true) == OK:
				var temp_std_audio_preset : String = ""
				while true:
					temp_std_audio_preset = dir.get_next()
					if temp_std_audio_preset == "":
						break;
					if dir.file_exists("res://src/Ressources/StdAudioPresets/" + temp_std_audio_preset):
						if dir.copy("res://src/Ressources/StdAudioPresets/" + temp_std_audio_preset,Global.GetCurrentUserDataFolder() + "/Settings/AudioEffects/Presets/" + temp_std_audio_preset.get_file() ) != OK:
							Global.root.message("COPYING STANDARD PRESET FILE TO USERDATA",SaveData.MESSAGE_ERROR, false, Color() )
				SaveData.save(SongLists.AddUserToFilepath( SongLists.FilePaths[17] ),true)
		else:
			Global.root.message("StdAudioPresets couldn't be loaded", SaveData.MESSAGE_ERROR) 


func copy_export_templates() -> void:
	# copying the Templates since there is bug which prevent files that are not ressource file from being read on export
	var dir : Directory = Directory.new()
	
	# copying HTML Templates
	var _err = dir.copy("res://src/Scenes/Export/HTMLTemplate/SonglistTemplate.html","user://GlobalSettings/ExportTemplates/SonglistTemplate.html")
	_err = dir.copy("res://src/Scenes/Export/HTMLTemplate/GeneralTemplate.html","user://GlobalSettings/ExportTemplates/GeneralTemplate.html")


func init_std_covers() -> void:
	var std_cover_path : String = SettingsData.GetSetting( SettingsData.SONG_SETTINGS, "StandardSongCover")
	Global.std_cover = ImageLoader.get_cover( std_cover_path )
	Global.std_music_cover = ImageLoader.get_cover( std_cover_path )


