extends PanelContainer

#CONSTANTS
const Methods : Array = [ "ToFolder", "ToHTMLSonglist", "ToCSV",]
const SaveTypes : Array = ["ExportFolder", "ExportHTML", "ExportCSV"]
const FileFilters : Array = [null,"*.html", "*.csv"]
const Modes : Array = [FileDialog.MODE_OPEN_DIR, FileDialog.MODE_SAVE_FILE, FileDialog.MODE_SAVE_FILE]

#NODES
onready var ExportTypes : VBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/ExportTypes

func _enter_tree():
	Global.root.ToggleSongScrollerInput( false )


func _exit_tree():
	Global.root.ToggleSongScrollerInput( true )


func InitPlaylistExportMenu(var PlaylistIdx : int) -> void:
	var Export : Exporter = Exporter.new()
	for i in ExportTypes.get_child_count() - 1:
		var _err = ExportTypes.get_child(i).connect("pressed",Global.root,"OpenGeneralFileDialogue",[
			Export,
			Modes[i],
			FileDialog.ACCESS_FILESYSTEM,
			Methods[i],
			[Playlist.GetPlaylistPaths(PlaylistIdx), PlaylistIdx],
			SaveTypes[i],
			[FileFilters[i]],
			true
		])
		_err = ExportTypes.get_child(i).connect("pressed",self,"queue_free")
