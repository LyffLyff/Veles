extends PanelContainer

#NODES
onready var ProfileHBox : HBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/ProfileHBox


func _enter_tree():
	Global.root.ToggleSongScrollerInput(false)


func _exit_tree():
	Global.root.ToggleSongScrollerInput(true)


func _ready():
	LoadUserProfiles()


func LoadUserProfiles() -> void:
	FreeUserProfiles()
	Global.PriorUser = Global.GetCurrentUser()
	for i in Global.UserProfiles.size():
		var x = load("res://src/Scenes/UserProfiles/UserProfileContainer.tscn").instance()
		x.connect("RightClicked",self,"LoadUserOptions",[i])
		x.connect("pressed",self,"OnUserProfileSelected",[i])
		ProfileHBox.add_child(x)
		x.Username.set_text(Global.UserProfiles[i])
		x.ProfileImg.set_texture( ImageLoader.GetCover("user://GlobalSettings/UserImages/" + Global.UserProfiles[i] + ".png") )
		ProfileHBox.move_child(x,0)


func FreeUserProfiles() -> void:
	for i in ProfileHBox.get_child_count() - 1:
		#-1 -> Skipping the AddProfile button
		ProfileHBox.get_child(i).queue_free()


func OnUserProfileSelected(var UserIdx : int) -> void:
	#Saving the Data of the Previous user then loading the one from the new one
	var Paths : PoolStringArray = []
	for i in SongLists.FilePaths.size():
		Paths.push_back( SongLists.AddUserToFilepath(SongLists.FilePaths[i]) )
	SongLists.SaveUserSpecificData(Paths)
	Global.CurrentProfileIdx = UserIdx
	Global.InitializeSongs = true
	SongLists.ResetUserdata()
	SongLists.LoadUserSpecificData(SongLists.FilePaths)
	var init : VelesInit = VelesInit.new()
	init.CreateFolders()
	init.CopyAudioPresets()
	init.CopyExportTemplates()
	init.InitAudioEffects()
	
	#Setting Std Download Folder
	if !SaveData.Load(SongLists.AddUserToFilepath(SongLists.FilePaths[0])):
		SongLists.AddFolder(Global.GetCurrentUserDataFolder() + "/Downloads")
	
	self.queue_free()


func OnAddUserPressed() -> void:
	var x = load("res://src/Scenes/UserProfiles/CreateUserProfile.tscn").instance()
	var _err = x.connect("tree_exited",self,"LoadUserProfiles")
	self.add_child(x)


func LoadUserOptions(var UserIdx : int) -> void:
	var x : Node = load("res://src/Scenes/UserProfiles/UserProfileOptions.tscn").instance()
	Global.root.add_child(x)
	x.rect_global_position = get_global_mouse_position()
	x.rect_global_position.y -= 30
	x.rect_global_position.x -= (x.rect_size.x / 2)
	
	#Profile Options
	var _err = x.Delete.connect("pressed",self,"OnDeleteUser",[UserIdx])
	_err = x.Delete.connect("pressed",x,"queue_free")
	_err = x.Rename.connect("pressed",self,"OnRenameUser",[UserIdx])
	_err = x.ChangeCover.connect("pressed",self,"OnChangeCover",[UserIdx])


func OnChangeCover(var UserIdx : int) -> void:
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	var _err = x.connect("TextSave",Global,"ChangeUserCover",[UserIdx])
	_err = x.connect("tree_exited",self,"LoadUserProfiles")
	Global.root.add_child(x)
	x.SetTopic("Change User Profile Image")
	x.InitDialogueButton(FileDialog.MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, "Cover", Global.SupportedImgFormats)


func OnRenameUser(var UserIdx : int) -> void:
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	var _err = x.connect("TextSave",Global,"RenameUser",[UserIdx])
	_err = x.connect("tree_exited",self,"LoadUserProfiles")
	Global.root.add_child(x)
	x.SetTopic("Rename User Profile")


func OnDeleteUser(var UserIdx : int) -> void:
	var Username : String = Global.UserProfiles[UserIdx]
	
	#Removing Folders Containing the Users specific data
	Global.RemoveUser(UserIdx)
	FileChecker.RemoveFolderRecursive( Global.GetCurrentUserDataFolder() )
	
	#Removing the users profile image
	var dir : Directory = Directory.new()
	var user_img : String = "user://GlobalSettings/UserImages/" + Username + ".png"
	if dir.file_exists( user_img ):
		var _err = dir.remove(user_img)
	
	#If the Deleted is the Current User
	if Username == Global.PriorUser:
		Global.PriorUser = ""
		Global.CurrentProfileIdx = -1
		Global.root.player.InitPlayer()
		if MainStream.stream:
			MainStream.set_stream(null)
			MainStream.set_stream_paused(true)
	
	#Reloading Profiles
	LoadUserProfiles()
