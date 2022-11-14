extends Reference

class_name HTML

#CONSTANTS
const RowTemplate : String = "					<th>CONTENT</th>\n"
const TableStart : String = "            <table>\n"
const TableEnd : String = "            </table>\n"
const ColumnStartTemplate : String = "				<tr>\n"
const ColumnEndTemplate : String = "				</tr>\n"
const SonglistRowTemplate : String = """
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


func FormatHTMLHeader(var HTMLFile  : String, var Title : String = "", var Headline : String = "") -> String:
	#Title
	HTMLFile = HTMLFile.format(
		[Title],
		"TITLE"
		)
	
	#h1
	HTMLFile = HTMLFile.format(
		[Headline],
		"HEADLINE"
		)
	return HTMLFile

func CreateHTMLSonglist(var SongPaths : PoolStringArray, var HeaderTitle : String = "") -> String:
	Global.root.message(SongPaths.join("\n"), SaveData.MESSAGE_NOTICE)
	var Pos : int = -1
	var HTMLFile : String =  SaveData.LoadAsText("user://GlobalSettings/ExportTemplates/SonglistTemplate.html")

	#Formatting Html Template File with the given Data
	
	#HTML/CSS Doc Options -> f.e. Design Options 
	HTMLFile = FormatHTMLHeader(HTMLFile,HeaderTitle,HeaderTitle)

	for i in SongPaths.size():
		Pos = HTMLFile.find_last("</tr>") + 5
		HTMLFile = HTMLFile.insert(Pos, SonglistRowTemplate )
		HTMLFile = HTMLFile.format(
			[Tags.GetTitle(SongPaths[i])],
			"TITLE"
			)
		HTMLFile = HTMLFile.format(
			[Tags.GetArtist(SongPaths[i])],
			"ARTIST"
			)
		HTMLFile = HTMLFile.format(
			[ Tags.GetAlbum(SongPaths[i]) ],
			"ALBUM"
			)
		HTMLFile = HTMLFile.format(
			[ Tags.GetGenre(SongPaths[i]) ],
			"GENRE"
			)
		HTMLFile = HTMLFile.format(
			[ Tags.GetMultipleTags(SongPaths[i], [6])[0] ],
			"TRACK"
			)
		HTMLFile = HTMLFile.format(
			[ Tags.GetMultipleTags(SongPaths[i], [5])[0] ],
			"YEAR"
			)
		HTMLFile = HTMLFile.format(
			[ TimeFormatter.FormatSeconds( Tags.GetSongDuration( SongPaths[i] ) ) ],
			"SONGLENGTH"
			)
		HTMLFile = HTMLFile.format(
			[ SongPaths[i].get_file() ],
			"FILENAME"
			)
		HTMLFile = HTMLFile.format(
			[ FormatChecker.GetMusicFormatExtension( SongPaths[i] ) ],
			"FILEFORMAT"
			)

	return HTMLFile;


func CreateTable(var Content : Array,var Title : String = "", var Headline : String = "") -> String:
	#Gets a two dimensional array, which will be represented as HTML
	var HTMLTable : String = ""
	HTMLTable += TableStart
	
	for i in Content.size():
		HTMLTable += ColumnStartTemplate
		for j in Content[i].size():
			HTMLTable += RowTemplate.format([Content[i][j]],"CONTENT")
		HTMLTable += ColumnEndTemplate
	HTMLTable += TableEnd
	var GeneralTemplate : String = SaveData.LoadAsText("user://GlobalSettings/ExportTemplates/GeneralTemplate.html").format(
		[HTMLTable],
		"BODY"
	)
	return FormatHTMLHeader( GeneralTemplate, Title, Headline )
