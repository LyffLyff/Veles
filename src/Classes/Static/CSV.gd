extends Object

class_name CSV


func EncodeSonglistInCSV(var SongPaths : PoolStringArray) -> String:
	var EncodedCSVFile : String = ""
	
	#Header
	EncodedCSVFile += "Title;Artist;Album;Genre;Track;Year;Fileformat;Filename\n"
	
	#Song Tags
	var TempTags : PoolStringArray = []
	for i in SongPaths.size():
		for Tag in Tags.GetMultipleTags(SongPaths[i],[1,0,2,3,6,5]):
			EncodedCSVFile += Tag + ";"
		EncodedCSVFile += FormatChecker.GetMusicFormatExtension( SongPaths[i] ) + ";"
		EncodedCSVFile += SongPaths[i].get_file() + ";"
		EncodedCSVFile += "\n"
	
	#Footer
	EncodedCSVFile = AddFooter(EncodedCSVFile)
	
	return EncodedCSVFile


func CreateCSVTable(var ContentGrid : Array, var Header : PoolStringArray = []) -> String:
	var EncodedCSVFile : String = ""
	
	#Header
	for i in Header.size():
		EncodedCSVFile += Header[i] + ";"
	EncodedCSVFile += "\n"
	
	#Content
	for i in ContentGrid.size():
		for j in ContentGrid[i].size():
			EncodedCSVFile += ContentGrid[i][j] + ";"
		EncodedCSVFile += "\n"
	
	#Footer
	EncodedCSVFile = AddFooter(EncodedCSVFile)
	
	return EncodedCSVFile


func AddFooter(var CSVFile : String) -> String:
	var Date : Dictionary = OS.get_datetime()
	CSVFile += "Created On: " + TimeFormatter.FormatDate(Date["day"], Date["month"], Date["year"]) + "\n"
	CSVFile += "Created using:;Veles;https://lyfflyff.itch.io/veles"
	return CSVFile;


