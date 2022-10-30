#Export Class
#A class that Handles multiple ways Veles allows to export Images and Songs

extends Object

class_name Exporter


func ToFolder(var DstFolderPath : String, var SongPaths : PoolStringArray, var PlaylistIdx : int = -1) -> bool:
	var Title : String = Playlist.GetPlaylistName(PlaylistIdx)
	var dir : Directory = Directory.new()
	var TempDstFolder : String = ""

	if dir.make_dir_recursive(DstFolderPath + "/" + Title) != OK:
		return false;

	for i in SongPaths.size():
		TempDstFolder = DstFolderPath + "/" + Title + "/" + SongPaths[i].get_file()
		if dir.copy(SongPaths[i], DstFolderPath + "/" + Title + "/" + SongPaths[i].get_file() ) != OK:
			Global.root.Message("COPYING FILE: " + SongPaths[i] + "TO: " + TempDstFolder,SaveData.MESSAGE_ERROR)

	return true;


func ToHTMLSonglist(var DstPath : String, var SongPaths : PoolStringArray, var _PlaylistIdx : int = -1) -> void:
	var HTMLFile : String = HTML.new().CreateHTMLSonglist(SongPaths)
	#Save To Export Destination
	SaveData.SaveAsText(DstPath, HTMLFile)
	var _err = OS.shell_open(DstPath)


func ToHTMLTable(var DstPath : String, var ContentGrid : Array) -> void:
	
	var HTMLFile : String = HTML.new().CreateTable(ContentGrid, DstPath.get_file(), DstPath.get_file())
	#Save To Export Destination
	SaveData.SaveAsText(DstPath, HTMLFile)
	var _err = OS.shell_open(DstPath)


func ToImage(var DstPath : String, var SongPaths : PoolStringArray) -> void:
	var NewDstPaths : PoolStringArray = []
	for i in SongPaths.size():
		NewDstPaths.push_back(
			DstPath.replace(
				"." + DstPath.get_extension(),
				""
			) + "-(" + str(i + 1) + ")" + "." + DstPath.get_extension()
		)
	
	if !Tags.CopyCovers(SongPaths, NewDstPaths)[0]:
		Global.root.Message(
			"EXCTRACTING COVER FROM FILES: " + SongPaths.join(", ") + " TO:" + NewDstPaths.join(", "),
			SaveData.MESSAGE_ERROR,
			Color(),
			false
		)


func ToCSV(var DstPath : String, var SongPaths : PoolStringArray, var _PlaylistIdx : int = -1) -> void:
	var CSVFile : String = CSV.new().EncodeSonglistInCSV(SongPaths)
	SaveData.SaveAsText(DstPath, CSVFile)
	var _err = OS.shell_open(DstPath)


func ToCSVTable(var DstPath : String, var ContentGrid : Array) -> void:
	var CSVFile : String = CSV.new().CreateCSVTable(ContentGrid)
	SaveData.SaveAsText(DstPath, CSVFile)
	var _err = OS.shell_open(DstPath)


func ToLRC(var DstPath : String, var LRCFileData : String) -> void:
	SaveData.SaveAsText(DstPath, LRCFileData)
	var _err = OS.shell_open(DstPath)
