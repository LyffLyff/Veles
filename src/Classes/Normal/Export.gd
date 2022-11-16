class_name Exporter extends Object
# a class that handles multiple ways Veles allows to export images, songs, lyrics,...


func to_folder(var dst_folder : String, var song_paths : PoolStringArray, var playlist_idx : int = -1) -> bool:
	var Title : String = Playlist.get_playlist_name(playlist_idx)
	var dir : Directory = Directory.new()
	var Tempdst_folder : String = ""

	if dir.make_dir_recursive(dst_folder + "/" + Title) != OK:
		return false;

	for i in song_paths.size():
		Tempdst_folder = dst_folder + "/" + Title + "/" + song_paths[i].get_file()
		if dir.copy(song_paths[i], dst_folder + "/" + Title + "/" + song_paths[i].get_file() ) != OK:
			Global.root.message("COPYING FILE: " + song_paths[i] + "TO: " + Tempdst_folder,SaveData.MESSAGE_ERROR)

	return true;


func to_html_songlist(var dst_file : String, var song_paths : PoolStringArray, var _playlist_idx : int = -1) -> void:
	var html_file_path : String = HTML.new().create_html_songlist(song_paths)
	#Save To Export Destination
	SaveData.save_as_text(dst_file, html_file_path)
	var _err = OS.shell_open(dst_file)


func to_html_table(var dst_file : String, var content : Array) -> void:
	var html_file_path : String = HTML.new().create_table(content, dst_file.get_file(), dst_file.get_file())
	
	# save To Export Destination
	SaveData.save_as_text(dst_file, html_file_path)
	var _err = OS.shell_open(dst_file)


func to_image(var dst_path : String, var song_paths : PoolStringArray) -> void:
	var dst_paths : PoolStringArray = []
	
	for i in song_paths.size():
		dst_paths.push_back(
			dst_path.replace(
				"." + dst_path.get_extension(),
				""
			) + "-(" + str(i + 1) + ")" + "." + dst_path.get_extension()
		)
	
	if !Tags.copy_embedded_covers(song_paths, dst_paths)[0]:
		Global.root.message(
			"EXCTRACTING COVER FROM FILES: " + song_paths.join(", ") + " TO:" + dst_paths.join(", "),
			SaveData.MESSAGE_ERROR,
			Color(),
			false
		)


func to_CSV(var dst_path : String, var song_paths : PoolStringArray, var _playlist_idx : int = -1) -> void:
	var csv_data : String = CSV.new().encode_songlist(song_paths)
	SaveData.save_as_text(dst_path, csv_data)
	var _err = OS.shell_open(dst_path)


func to_CSV_table(var dst_path : String, var content : Array) -> void:
	var csv_data : String = CSV.new().create_csv_table(content)
	SaveData.save_as_text(dst_path, csv_data)
	var _err = OS.shell_open(dst_path)


func to_LRC(var dst_path : String, var lrc_data : String) -> void:
	# saves the data of a LRC file to destination as text
	SaveData.save_as_text(dst_path, lrc_data)
	var _err = OS.shell_open(dst_path)

