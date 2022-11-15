extends PanelContainer
# the script for the statisitc export menu
# it directs the app to the correct export function on a button press in the menu

const export_methods : Array = ["to_html_table", "to_CSV_table",]
const save_types : Array = ["ExportHTML", "ExportCSV"]
const file_filters : Array = ["*.html", "*.csv"]
const open_modes : Array = [FileDialog.MODE_SAVE_FILE, FileDialog.MODE_SAVE_FILE]

onready var export_types : VBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/export_types


func _enter_tree():
	Global.root.toggle_songlist_input( false )


func _exit_tree():
	Global.root.toggle_songlist_input( true )


func init_export_menu(var content : Array) -> void:
	var exporter : Exporter = Exporter.new()
	for i in export_types.get_child_count() - 1:
		var _err = export_types.get_child(i).connect("pressed",Global.root,"load_general_file_dialogue",[
			exporter,
			open_modes[i],
			FileDialog.ACCESS_FILESYSTEM,
			export_methods[i],
			[content],
			save_types[i],
			[file_filters[i]],
			true
		])
		_err = export_types.get_child(i).connect("pressed",self,"queue_free")
