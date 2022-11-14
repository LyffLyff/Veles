class_name CSV extends Object

func encode_songlist(var song_paths : PoolStringArray) -> String:
	var encoded_csv_file : String = ""
	
	# header
	encoded_csv_file += "Title;Artist;Album;Genre;Track;Year;Fileformat;Filename\n"
	
	# song Tags
	var TempTags : PoolStringArray = []
	for i in song_paths.size():
		for tag in Tags.get_text_tags(song_paths[i],[1,0,2,3,6,5]):
			encoded_csv_file += tag + ";"
		encoded_csv_file += FormatChecker.get_music_file_extension( song_paths[i] ) + ";"
		encoded_csv_file += song_paths[i].get_file() + ";"
		encoded_csv_file += "\n"
	
	# footer
	encoded_csv_file = add_footer(encoded_csv_file)
	
	return encoded_csv_file


func create_csv_table(var content : Array, var header : PoolStringArray = []) -> String:
	var encoded_csv_file : String = ""
	
	# header
	for i in header.size():
		encoded_csv_file += header[i] + ";"
	encoded_csv_file += "\n"
	
	# content
	for i in content.size():
		for j in content[i].size():
			encoded_csv_file += content[i][j] + ";"
		encoded_csv_file += "\n"
	
	# footer
	encoded_csv_file = add_footer(encoded_csv_file)
	
	return encoded_csv_file


func add_footer(var csv_data : String) -> String:
	var current_date : Dictionary = OS.get_datetime()
	csv_data += "Created On: " + TimeFormatter.format_date(current_date["day"], current_date["month"], current_date["year"]) + "\n"
	csv_data += "Created using:;Veles;https://lyfflyff.itch.io/veles"
	return csv_data;

