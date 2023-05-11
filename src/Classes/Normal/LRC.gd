class_name LRC extends Reference
# the .lrc file format is a format used to synchronize lyrics to an audiofile
# it can be used in the formats MP3, OGG Vorbis and MIDI
# this class will hold function to create and read .lrc files and make them into lyric editor projects
# [mm:ss.cc][Minutes:Seconds:Hundreeths]
# the . between ss and cc can also be a : depending on the program used -> Veles uses .
# [ar: Artist/s]
# [al: Album, from where this Song originates from]
# [ti: Title of Song]
# [au: Author and/or Composer]
# [length: Length of Audio File]
# [la: Two Letters representing the Langauge of Lyrics in ISO-639-1 Notation]
# [by:Creator of this LRC-File]
# [re:Veles -> Automatic]
# [ve:Veles Version -> Automatic]

const info_tags : Dictionary = {
	"ar:" : "",
	"al:" : "",
	"ti:" : "",
	"au:" : "",
	"length:" : "",
	"la:" : "",
	"by:" : "",
	"re:" : "",
	"ve:" : ""
}


func encode_lrc_file(
	var verses : PoolStringArray,
	var timestamps_in_seconds : PoolRealArray = [],
	var artist : String = "",
	var album : String = "",
	var title : String = "",
	var author : String = "",
	var song_length : String = "",
	var language : String = "",
	var creator_of_lrc_file : String = ""
	) -> String:
	
	var lrc_file : String = ""
	
	# header
	lrc_file += "[re:Veles Music Tool https://lyfflyff.itch.io/veles]\n"
	if artist.length() > 0:
		lrc_file += "[" + info_tags.keys()[0] + artist + "]" + "\n"
	if album.length() > 0:
		lrc_file += "[" + info_tags.keys()[1] + album + "]" + "\n"
	if title.length() > 0:
		lrc_file += "[" + info_tags.keys()[2] + title + "]" + "\n"
	if author.length() > 0:
		lrc_file += "[" + info_tags.keys()[3] + author + "]" + "\n"
	if song_length != "":
		lrc_file += "[" + info_tags.keys()[4] + song_length + "]" + "\n"
	if language != "":
		# the given Language will always be in the right format
		lrc_file += "[" + info_tags.keys()[5] + language + "]" + "\n"
	if creator_of_lrc_file != "":
		lrc_file += "[" + info_tags.keys()[6] + creator_of_lrc_file + "]" + "\n"
	
	# lyrics
	var temp_timestamp : String = ""
	for i in verses.size():
		if timestamps_in_seconds.size() > i:
			temp_timestamp = TimeFormatter.seconds_to_lrc_timestamp(timestamps_in_seconds[i])
		else:
			temp_timestamp = "[00:00.00]"
		lrc_file += temp_timestamp + verses[i] + "\n"
	
	# erasing the last Newline from the file, since it's not needed
	lrc_file.erase(lrc_file.length() - 1,2)
	
	return lrc_file


func decode_lrc_file(var lrc_data : String) -> Array:
	# this function Returns an Array with all the possible properties of a LRC File
	# if the property does not exist in the LRC file it will be set as the Variant, but empty
	var decoded_lrc_file : Array = [info_tags]
	
	# header
	var prior_open_bracket_idx : int = -1
	var open_bracket_idx : int = -1
	var close_bracket_idx : int = -1
	var colon_idx : int = -1
	var temp_lrc_tag : String = ""
	var temp_lrc_tag_data : String = ""
	
	while true:
		prior_open_bracket_idx = open_bracket_idx
		open_bracket_idx = lrc_data.find("[",open_bracket_idx + 1)
		close_bracket_idx = lrc_data.find("]",open_bracket_idx + 1)
		colon_idx = lrc_data.find(":",open_bracket_idx + 1)
		temp_lrc_tag = lrc_data.substr(open_bracket_idx + 1, colon_idx - open_bracket_idx)
		if info_tags.has(temp_lrc_tag):
			
			# getting the LRC Tag Data if the Tag is valid
			temp_lrc_tag_data = lrc_data.substr(colon_idx + 1, close_bracket_idx - colon_idx - 1)
			decoded_lrc_file[0][temp_lrc_tag] = temp_lrc_tag_data
		else:
			break;
	
	# lyrics
	var Verses : PoolStringArray = []
	var timestamps : PoolRealArray = []
	
	while true:
		
		# retrieving Timestamp
		timestamps.push_back(
			TimeFormatter.lrc_timestamp_to_seconds(
				lrc_data.substr(open_bracket_idx, close_bracket_idx - open_bracket_idx)
			)
		)
		
		# retrieving Corresponding Verse
		open_bracket_idx = lrc_data.find("[",close_bracket_idx)
		
		# checking for end of LRC File
		if open_bracket_idx == -1:
			
			# if this is the Last verse to add and not the only verse
			Verses.push_back(
				lrc_data.substr(close_bracket_idx + 1, lrc_data.length() - close_bracket_idx - 1)
			)
			break;
		else:
			
			# if there is another verse to add
			Verses.push_back(
				lrc_data.substr(close_bracket_idx + 1, open_bracket_idx - close_bracket_idx - 2)
			)
			close_bracket_idx = lrc_data.find("]",open_bracket_idx + 1)
	
	decoded_lrc_file.push_back(Verses)
	decoded_lrc_file.push_back(timestamps)
	
	# returning the Decoded LRC Files as Array
	# [{LRC_TAGS}, Verses, timestamps]
	return decoded_lrc_file;
