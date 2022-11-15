extends PanelContainer
# the script for the playlists export menu
# it directs the app to the correct export function on a button press in the menu

const export_methods : Array = [ "to_folder", "to_html_songlist", "to_CSV",]
const save_types : Array = ["ExportFolder", "ExportHTML", "ExportCSV"]
const file_filters : Array = [null,"*.html", "*.csv"]
const open_modes : Array = [FileDialog.MODE_OPEN_DIR, FileDialog.MODE_SAVE_FILE, FileDialog.MODE_SAVE_FILE]

onready var export_types : VBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/export_types


func _enter_tree():
	Global.root.toggle_songlist_input( false )


func _exit_tree():
	Global.root.toggle_songlist_input( true )


func init_export_menu(var playlist_idx : int) -> void:
	var exporter : Exporter = Exporter.new()
	for i in export_types.get_child_count() - 1:
		var _err = export_types.get_child(i).connect("pressed",Global.root,"load_general_file_dialogue",[
			exporter,
			open_modes[i],
			FileDialog.ACCESS_FILESYSTEM,
			export_methods[i],
			[Playlist.get_playlist_paths(playlist_idx), playlist_idx],
			save_types[i],
			[file_filters[i]],
			true
		])
		_err = export_types.get_child(i).connect("pressed",self,"queue_free")
