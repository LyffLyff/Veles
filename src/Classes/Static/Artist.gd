class_name Artist extends GDScript



static func divide_artists(var artists_string : String) -> PoolStringArray:
	var divided_artists : PoolStringArray = []
	var temp_string : String = ""
	
	for ch in artists_string:
		if ch == ',':
			divided_artists.append(temp_string.strip_edges())
			temp_string = ""
		else:
			temp_string += ch
	
	divided_artists.append(temp_string.strip_edges())
	
	return divided_artists


static func combine_artists(var artist_list : PoolStringArray) -> String:
	var combined_artists : String = ""
	for i in artist_list.size():
		combined_artists += artist_list[i]
		if i + 1 == artist_list.size():
			break;
		else:
			if artist_list[i + 1] != "":
				combined_artists += ", "
	return combined_artists 


static func load_artist_playlist(var artist_name : String) -> void:
	var divided_artists : PoolStringArray = divide_artists(artist_name)
	
	Global.root.load_temporary_playlist( 
		artist_name,
		Global.get_current_user_data_folder() + "/Songs/Artists/Descriptions/" + artist_name + ".txt",
		Global.get_current_user_data_folder() + "/Songs/Artists/Covers/" + artist_name + ".png",
		{"includes_either_artist" : [divided_artists]},
		3
	)
