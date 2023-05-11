extends PanelContainer

onready var current_directory = $PanelContainer/MainBody/Filesystem/ScrollContainer/CurrentDirectory

var current_directory_content : PoolStringArray = []
var current_directory_path : String = "C:/"
var err : int = -1

func _ready():
	load_directory("C://CodeBlocks")


func load_directory(var directory_path : String) -> void:
	clear_current_directory()
	var content : PoolStringArray = ExtendedDirectory.(directory_path, [])
	var dir : Directory = Directory.new()
	
	current_directory_content = content
	current_directory_path = directory_path
	
	for i in content.size():
		var x : Button = Button.new()
		x.text = content[i].get_file()
		if dir.file_exists(content[i]):
			# is file
			print("FILE: ", content[i])
			current_directory.add_child(x)
			err = x.connect("pressed", self, "on_file_tem_pressed", [i])
		else:
			# is directory
			print("DIR: ", content[i])
			current_directory.add_child(x)
			err = x.connect("pressed", self, "on_directory_item_pressed", [i])


func clear_current_directory() -> void:
	# clears all items added to the file / folder list
	for item in current_directory.get_children():
		item.queue_free()


func on_file_tem_pressed(var content_idx : int) -> void:
	print(current_directory_content[content_idx])


func on_directory_item_pressed(var content_idx : int) -> void:
	# loads pressed directory
	print(current_directory_content[content_idx])
	load_directory(current_directory_content[content_idx])



func _on_ParentDirectory_pressed():
	# loads the parent directory relative to the currently loaded one
	load_directory(current_directory_path.get_base_dir())
