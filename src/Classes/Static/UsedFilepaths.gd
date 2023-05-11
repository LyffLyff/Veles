class_name UsedFilepaths extends Reference

enum {
	TAG_PATH,
	TAG_COVER,
	EXPORT_COVER,
	PLAYLIST_HEADER
	USER_COVER
	ADD_FOLDER,
	LRC_FILE,
	EMBED_LYRICS,
	HTML_FILE,
	CSV_FILE,
	DESKTOP,
	VPL_PROJECT,
	DOWNLOAD_FOLDER
}

static func get_filepath() -> String:
	return SongLists.add_user_to_filepath(SongLists.file_paths[18])


static func get_used_filepath(var filetype_idx : int) -> String:
	var filepaths = SaveData.load_data(get_filepath())
	return filepaths[filetype_idx] if (filepaths != null and filepaths.has(filetype_idx)) else OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)


static func save_filepath_type(var filetype_idx : int, var used_path : String) -> void:
	if filetype_idx == DESKTOP:
		# if the filetype is set to DESKTOP the change will not be saved
		# so everytime it will be desktop
		return
	var used_filepaths = SaveData.load_data(get_filepath())
	if !used_filepaths:
		used_filepaths = {
			DESKTOP : OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		}
	used_filepaths[filetype_idx] = used_path
	SaveData.save(get_filepath(), used_filepaths)
