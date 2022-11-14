extends PanelContainer

#CONSTANTS
const Methods : Array = [ "to_folder", "to_html_songlist", "to_CSV",]
const SaveTypes : Array = ["ExportFolder", "ExportHTML", "ExportCSV"]
const FileFilters : Array = [null,"*.html", "*.csv"]
const Modes : Array = [FileDialog.MODE_OPEN_DIR, FileDialog.MODE_SAVE_FILE, FileDialog.MODE_SAVE_FILE]

#NODES
onready var ExportTypes : VBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/ExportTypes

func _enter_tree():
	Global.root.toggle_songlist_input( false )


func _exit_tree():
	Global.root.toggle_songlist_input( true )


func InitPlaylistExportMenu(var playlist_idx : int) -> void:
	var Export : Exporter = Exporter.new()
	for i in ExportTypes.get_child_count() - 1:
		var _err = ExportTypes.get_child(i).connect("pressed",Global.root,"load_general_file_dialogue",[
			Export,
			Modes[i],
			FileDialog.ACCESS_FILESYSTEM,
			Methods[i],
			[Playlist.get_playlist_paths(playlist_idx), playlist_idx],
			SaveTypes[i],
			[FileFilters[i]],
			true
		])
		_err = ExportTypes.get_child(i).connect("pressed",self,"queue_free")
