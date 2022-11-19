class_name HTML extends Reference
# a class for the export of data from Veles to html files

const row_template : String = "					<th>CONTENT</th>\n"
const table_start : String = "            <table>\n"
const table_end : String = "            </table>\n"
const column_start_template : String = "				<tr>\n"
const column_end_template : String = "				</tr>\n"
const songlist_row_template : String = """
				<tr>
					<th>TITLE</th>
					<th>ARTIST</th>
					<th>ALBUM</th>
					<th>GENRE</th>
					<th>TRACK</th>
					<th>YEAR</th>
					<th>SONGLENGTH</th>
					<th>FILEFORMAT</th>
					<th>FILENAME</th>
				</tr>"""


func format_html_header(var html_file  : String, var title : String = "", var headline : String = "") -> String:
	#title
	html_file = html_file.format(
		[title],
		"TITLE"
		)
	
	#h1
	html_file = html_file.format(
		[headline],
		"HEADLINE"
		)
	return html_file


func create_html_songlist(var song_paths : PoolStringArray, var header_title : String = "") -> String:
	# formatting html Template File with the given data
	
	Global.root.message(song_paths.join("\n"), SaveData.MESSAGE_NOTICE)
	var pos : int = -1
	var html_file : String =  SaveData.load_as_text("user://GlobalSettings/ExportTemplates/SonglistTemplate.html")
	
	#HTML/CSS Doc Options -> f.e. Design Options 
	html_file = format_html_header(html_file, header_title, header_title)

	for i in song_paths.size():
		pos = html_file.find_last("</tr>") + 5
		html_file = html_file.insert(pos, songlist_row_template )
		html_file = html_file.format(
			[Tags.get_title(song_paths[i])],
			"TITLE"
			)
		html_file = html_file.format(
			[Tags.get_artist(song_paths[i])],
			"ARTIST"
			)
		html_file = html_file.format(
			[ Tags.get_album(song_paths[i]) ],
			"ALBUM"
			)
		html_file = html_file.format(
			[ Tags.get_genre(song_paths[i]) ],
			"GENRE"
			)
		html_file = html_file.format(
			[ Tags.get_text_tags(song_paths[i], [6])[0] ],
			"TRACK"
			)
		html_file = html_file.format(
			[ Tags.get_text_tags(song_paths[i], [5])[0] ],
			"YEAR"
			)
		html_file = html_file.format(
			[ TimeFormatter.format_seconds( Tags.get_song_duration( song_paths[i] ) ) ],
			"SONGLENGTH"
			)
		html_file = html_file.format(
			[ song_paths[i].get_file() ],
			"FILENAME"
			)
		html_file = html_file.format(
			[ FormatChecker.get_music_file_extension( song_paths[i] ) ],
			"FILEFORMAT"
			)

	return html_file;


func create_table(var content : Array, var title : String = "", var headline : String = "") -> String:
	# encodes an array of content to a html table [i][0] = Column 1, [i][1] = Column 2,...
	var html_table : String = ""
	html_table += table_start
	
	for i in content.size():
		html_table += column_start_template
		for j in content[i].size():
			html_table += row_template.format([content[i][j]],"CONTENT")
		html_table += column_end_template
	html_table += table_end
	var general_template : String = SaveData.load_as_text("user://GlobalSettings/ExportTemplates/GeneralTemplate.html").format(
		[html_table],
		"BODY"
	)
	return format_html_header(general_template, title, headline)
