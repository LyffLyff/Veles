extends Control

const song_formats : Array = ["mp3","ogg","flac","wav","opus"]
const dialogue_song_formats : Array = ["*.mp3","*.ogg","*.flac","*.wav","*.opus"]

onready var file_tree : Tree = $VBoxContainer/HBoxContainer/ScrollContainer/FileTree

func _ready():
	init_file_tree()
	file_tree.set_hide_root(true)
	var x = []
	for i in 100:
		x.push_back("erguhvephnsödjnasödfjhdjfsdfsdfjjsdöf")
	set_file_tree(x)


func init_file_tree() -> void:
	file_tree.set_column_title(0, "Path:")
	file_tree.set_column_title(1, "Tag1:")


func set_file_tree(var filepaths : PoolStringArray) -> void:
	file_tree.clear()
	var temp_item : LineEdit
	for i in len(filepaths):
		temp_item = LineEdit.new()
		temp_item.rect_min_size.y = 15
		file_tree.create_item(
			null,
			i
		).set_text(0, filepaths[i])


func _on_FileTree_button_pressed(var item : TreeItem, var column : int, var id : int):
	print(item.text)


func _on_FileTree_item_selected():
	print("hm")


func _on_FileTree_cell_selected():
	print("jojojo")


func _on_OpenFiles_pressed():
	var dialog = Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"set_file_tree",
		[],
		UsedFilepaths.TAG_PATH,
		dialogue_song_formats,
		false,
		"Select Files"
	)
