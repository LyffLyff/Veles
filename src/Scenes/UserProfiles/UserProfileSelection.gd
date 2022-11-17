extends PanelContainer

onready var profile_list : HBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/ProfileHBox

func _ready():
	load_user_profiles()


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


func load_user_profiles() -> void:
	free_user_profiles()
	Global.last_loaded_user = Global.get_current_user()
	for i in Global.user_profiles.size():
		var x = load("res://src/Scenes/UserProfiles/UserProfileContainer.tscn").instance()
		x.connect("right_clicked",self,"load_user_options",[i])
		x.connect("pressed",self,"on_user_profile_selected",[i])
		profile_list.add_child(x)
		x.username.set_text(Global.user_profiles[i])
		x.profile_img.set_texture( ImageLoader.get_cover("user://GlobalSettings/UserImages/" + Global.user_profiles[i] + ".png") )
		profile_list.move_child(x,0)


func free_user_profiles() -> void:
	for i in profile_list.get_child_count() - 1:
		# -1 -> Skipping the AddProfile button
		profile_list.get_child(i).queue_free()


func on_user_profile_selected(var user_idx : int) -> void:
	# saving the Data of the Previous user then loading the one from the new one
	var Paths : PoolStringArray = []
	for i in SongLists.file_paths.size():
		Paths.push_back( SongLists.add_user_to_filepath(SongLists.file_paths[i]) )
	SongLists.save_user_specific_data(Paths)
	Global.current_profile_idx = user_idx
	Global.init_songs = true
	SongLists.reset_userdata()
	SongLists.load_user_specific_data(SongLists.file_paths)
	
	# initialising user profile
	var init : VelesInit = VelesInit.new()
	init.create_folders()
	init.copy_std_audio_presets()
	init.copy_export_templates()
	init.init_audio_effects()
	init.init_volume()
	
	# setting Std Download Folder
	if !SaveData.load_data(SongLists.add_user_to_filepath(SongLists.file_paths[0])):
		SongLists.add_folder(Global.get_current_user_data_folder() + "/Downloads")
	
	self.queue_free()


func load_user_options(var user_idx : int) -> void:
	var x : Node = load("res://src/Scenes/UserProfiles/UserProfileOptions.tscn").instance()
	Global.root.add_child(x)
	x.rect_global_position = get_global_mouse_position()
	x.rect_global_position.y -= 30
	x.rect_global_position.x -= (x.rect_size.x / 2)
	
	# profile Options
	var _err = x.delete.connect("pressed",self,"on_delete_pressed",[user_idx])
	_err = x.delete.connect("pressed",x,"queue_free")
	_err = x.rename.connect("pressed",self,"on_Rename_pressed",[user_idx])
	_err = x.change_cover.connect("pressed",self,"on_Change_Cover_pressed",[user_idx])


func _on_AddUser_pressed() -> void:
	var x = load("res://src/Scenes/UserProfiles/CreateUserProfile.tscn").instance()
	var _err = x.connect("tree_exited",self,"load_user_profiles")
	self.add_child(x)


func on_Change_Cover_pressed(var user_idx : int) -> void:
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	var _err = x.connect("text_saved",Global,"change_user_cover",[user_idx])
	_err = x.connect("tree_exited",self,"load_user_profiles")
	Global.root.add_child(x)
	x.set_topic("Change User Profile Image")
	x.init_dialogue_button(FileDialog.MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, "Cover", Global.supported_img_extensions)


func on_Rename_pressed(var user_idx : int) -> void:
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	var _err = x.connect("text_saved",Global,"rename_user",[user_idx])
	_err = x.connect("tree_exited",self,"load_user_profiles")
	Global.root.add_child(x)
	x.set_topic("Rename User Profile")


func on_delete_pressed(var user_idx : int) -> void:
	var username : String = Global.user_profiles[user_idx]
	
	# removing Folders Containing the Users specific data
	Global.remove_user(user_idx)
	ExtendedDirectory.remove_folder_recursive( Global.get_current_user_data_folder() )
	
	# removing the users profile image
	var dir : Directory = Directory.new()
	var user_img : String = "user://GlobalSettings/UserImages/" + username + ".png"
	if dir.file_exists( user_img ):
		var _err = dir.remove(user_img)
	
	# if the Deleted is the Current User
	if username == Global.last_loaded_user:
		Global.last_loaded_user = ""
		Global.current_profile_idx = -1
		Global.root.player.init_player()
		if MainStream.stream:
			MainStream.set_stream(null)
			MainStream.set_stream_paused(true)
	
	# reloading Profiles
	load_user_profiles()
