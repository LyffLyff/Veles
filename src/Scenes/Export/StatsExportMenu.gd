extends PanelContainer

#CONSTANTS
const Methods : Array = ["ToHTMLTable", "ToCSVTable",]
const SaveTypes : Array = ["ExportHTML", "ExportCSV"]
const FileFilters : Array = ["*.html", "*.csv"]
const Modes : Array = [FileDialog.MODE_SAVE_FILE, FileDialog.MODE_SAVE_FILE]

#NODES
onready var ExportTypes : VBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/ExportTypes

func _enter_tree():
	Global.root.ToggleSongScrollerInput( false )


func _exit_tree():
	Global.root.ToggleSongScrollerInput( true )


func InitStatsExportMenu(var ContentGrid : Array) -> void:
	var Export : Exporter = Exporter.new()
	for i in ExportTypes.get_child_count() - 1:
		var _err = ExportTypes.get_child(i).connect("pressed",Global.root,"OpenGeneralFileDialogue",[
			Export,
			Modes[i],
			FileDialog.ACCESS_FILESYSTEM,
			Methods[i],
			[ContentGrid],
			SaveTypes[i],
			[FileFilters[i]],
			true
		])
		_err = ExportTypes.get_child(i).connect("pressed",self,"queue_free")
