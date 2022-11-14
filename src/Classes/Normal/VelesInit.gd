extends Reference


class_name VelesInit
#Class that holds function, that will ONLY be used at startup of this Application


func InitRandomSettings() -> void:
	#Init Config
	var config : ConfigFile = SaveData.LoadConfigFile("user://override.cfg")
	var property_path : String
	var config_val = null
	for config_section in config.get_sections():
		for section_key in config.get_section_keys(config_section):
			property_path = config_section + "/" + section_key
			config_val = SaveData.GetConfigValue(config_section, section_key)
			if !ProjectSettings.has_setting(property_path):
				continue;
			if ProjectSettings.get_setting(property_path) != config_val:
				ProjectSettings.set_setting(property_path, config_val )
	#var _err = ProjectSettings.save()
	
	#Init Random
	if AudioServer.get_device_list().has(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "AudioOutputDevice")):
		AudioServer.set_device( SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "AudioOutputDevice") )
	else:
		#if the Saved Audio Output Device cannot be found anymore
		#the default will be selected 
		AudioServer.set_device("Default")
	ProjectSettings.set_setting("rendering/environment/default_clear_color",Color("c52a2a2a"))


func CreateFolders():
	var dir : Directory = Directory.new()
	if dir.open("user://") == OK:
		#the folders inside this string array will be created if they not already exist 
		
		#Global Folders
		var GlobalFolders : PoolStringArray = [
			"GlobalSettings",
			"GlobalSettings/UserImages",
			"GlobalSettings/StdUserdata",
			"GlobalSettings/ExportTemplates",
			"GlobalSettings/AppStats"
		]
		for n in GlobalFolders.size():
			if !dir.dir_exists(GlobalFolders[n]):
				if dir.make_dir_recursive(GlobalFolders[n]) != OK:
					Global.root.message("CREATING" + GlobalFolders[n] + "FOLDER",SaveData.MESSAGE_ERROR)
		
		#User Specific Folders
		var UserSpecificFolders : PoolStringArray = [
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
		for Username in Global.UserProfiles:
			for n in UserSpecificFolders.size():
				if !dir.dir_exists(Global.GetCurrentUserDataFolder() + UserSpecificFolders[n]):
					if dir.make_dir_recursive("Users/" + Username  + "/" + UserSpecificFolders[n]) != OK:
						Global.root.message("CREATING" + UserSpecificFolders[n] + "FOLDER",SaveData.MESSAGE_ERROR)


func InitAudioEffects() -> void:
	var MainEnabled : bool = SongLists.AudioEffects[SongLists.AudioEffects.size() - 1]["main_enabled"]
	for i in SongLists.AudioEffects.size() - 1:
		# setting Effect Enabled
		AudioServer.set_bus_effect_enabled(
			0,
			i,
			SongLists.AudioEffects[i]["enabled"] and MainEnabled	# if main is not enabled the effects will be off
		)
		
		# setting Effect Values
		var x : AudioEffect = AudioServer.get_bus_effect(0,i)
		for j in range(1, SongLists.AudioEffects[i].size()):
			x.set( SongLists.AudioEffects[i].keys()[j], SongLists.AudioEffects[i].values()[j] )


func init_volume() -> void:
	MainStream.set_volume(
		db2linear(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "Volume"))
	)


func CopyAudioPresets() -> void:
	#Copying Standard Presets from project to userdata, on first time
	if !Directory.new().file_exists( SongLists.AddUserToFilepath( SongLists.FilePaths[17] ) ):
		var dir : Directory = Directory.new()
		if dir.open("res://src/Ressources/StdAudioPresets") == OK:
			if dir.list_dir_begin(true,true) == OK:
				var StdAudioPreset : String = ""
				while true:
					StdAudioPreset = dir.get_next()
					if StdAudioPreset == "":
						break;
					if dir.file_exists("res://src/Ressources/StdAudioPresets/" + StdAudioPreset):
						if dir.copy("res://src/Ressources/StdAudioPresets/" + StdAudioPreset,Global.GetCurrentUserDataFolder() + "/Settings/AudioEffects/Presets/" + StdAudioPreset.get_file() ) != OK:
							Global.root.message("COPYING STANDARD PRESET FILE TO USERDATA",SaveData.MESSAGE_ERROR, false, Color() )
				SaveData.Save(SongLists.AddUserToFilepath( SongLists.FilePaths[17] ),true)
		else:
			Global.root.message("StdAudioPresets couldn't be loaded", SaveData.MESSAGE_ERROR) 


func CopyExportTemplates() -> void:
	#Copying the Templates since there is bug which prevent files that are not ressource file from being read on export
	var dir : Directory = Directory.new()
	
	#Copying HTML Templates
	var _err = dir.copy("res://src/Scenes/Export/HTMLTemplate/SonglistTemplate.html","user://GlobalSettings/ExportTemplates/SonglistTemplate.html")
	_err = dir.copy("res://src/Scenes/Export/HTMLTemplate/GeneralTemplate.html","user://GlobalSettings/ExportTemplates/GeneralTemplate.html")


func InitStdCovers() -> void:
	var StdCoverPath : String = SettingsData.GetSetting( SettingsData.SONG_SETTINGS, "StandardSongCover")
	Global.std_cover = ImageLoader.GetCover( StdCoverPath )
	Global.std_music_cover = ImageLoader.GetCover( StdCoverPath )


