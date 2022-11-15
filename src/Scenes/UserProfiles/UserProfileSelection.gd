extends PanelContainer

#NODES
onready var ProfileHBox : HBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/ProfileHBox


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


func _ready():
	LoadUserProfiles()


func LoadUserProfiles() -> void:
	FreeUserProfiles()
	Global.last_loaded_user = Global.get_current_user()
	for i in Global.user_profiles.size():
		var x = load("res://src/Scenes/UserProfiles/UserProfileContainer.tscn").instance()
		x.connect("RightClicked",self,"LoadUserOptions",[i])
		x.connect("pressed",self,"OnUserProfileSelected",[i])
		ProfileHBox.add_child(x)
		x.Username.set_text(Global.user_profiles[i])
		x.ProfileImg.set_texture( ImageLoader.get_cover("user://GlobalSettings/UserImages/" + Global.user_profiles[i] + ".png") )
		ProfileHBox.move_child(x,0)


func FreeUserProfiles() -> void:
	for i in ProfileHBox.get_child_count() - 1:
		#-1 -> Skipping the AddProfile button
		ProfileHBox.get_child(i).queue_free()


func OnUserProfileSelected(var user_idx : int) -> void:
	#Saving the Data of the Previous user then loading the one from the new one
	var Paths : PoolStringArray = []
	for i in SongLists.file_paths.size():
		Paths.push_back( SongLists.add_user_to_filepath(SongLists.file_paths[i]) )
	SongLists.saveUserSpecificData(Paths)
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
	
	#Setting Std Download Folder
	if !SaveData.load_data(SongLists.add_user_to_filepath(SongLists.file_paths[0])):
		SongLists.add_folder(Global.get_current_user_data_folder() + "/Downloads")
	
	self.queue_free()


func OnAddUserPressed() -> void:
	var x = load("res://src/Scenes/UserProfiles/CreateUserProfile.tscn").instance()
	var _err = x.connect("tree_exited",self,"LoadUserProfiles")
	self.add_child(x)


func LoadUserOptions(var user_idx : int) -> void:
	var x : Node = load("res://src/Scenes/UserProfiles/UserProfileOptions.tscn").instance()
	Global.root.add_child(x)
	x.rect_global_position = get_global_mouse_position()
	x.rect_global_position.y -= 30
	x.rect_global_position.x -= (x.rect_size.x / 2)
	
	#Profile Options
	var _err = x.Delete.connect("pressed",self,"OnDeleteUser",[user_idx])
	_err = x.Delete.connect("pressed",x,"queue_free")
	_err = x.Rename.connect("pressed",self,"OnRenameUser",[user_idx])
	_err = x.ChangeCover.connect("pressed",self,"OnChangeCover",[user_idx])


func OnChangeCover(var user_idx : int) -> void:
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	var _err = x.connect("text_saved",Global,"change_user_cover",[user_idx])
	_err = x.connect("tree_exited",self,"LoadUserProfiles")
	Global.root.add_child(x)
	x.set_topic("Change User Profile Image")
	x.init_dialogue_button(FileDialog.MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, "Cover", Global.supported_img_extensions)


func OnRenameUser(var user_idx : int) -> void:
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	var _err = x.connect("text_saved",Global,"rename_user",[user_idx])
	_err = x.connect("tree_exited",self,"LoadUserProfiles")
	Global.root.add_child(x)
	x.set_topic("Rename User Profile")


func OnDeleteUser(var user_idx : int) -> void:
	var Username : String = Global.user_profiles[user_idx]
	
	#Removing Folders Containing the Users specific data
	Global.remove_user(user_idx)
	ExtendedDirectory.remove_folder_recursive( Global.get_current_user_data_folder() )
	
	#Removing the users profile image
	var dir : Directory = Directory.new()
	var user_img : String = "user://GlobalSettings/UserImages/" + Username + ".png"
	if dir.file_exists( user_img ):
		var _err = dir.remove(user_img)
	
	#If the Deleted is the Current User
	if Username == Global.last_loaded_user:
		Global.last_loaded_user = ""
		Global.current_profile_idx = -1
		Global.root.player.init_player()
		if MainStream.stream:
			MainStream.set_stream(null)
			MainStream.set_stream_paused(true)
	
	#Reloading Profiles
	LoadUserProfiles()
