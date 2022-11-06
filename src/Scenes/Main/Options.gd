extends VBoxContainer

#PRELOADS
const OptionUnpressed : Theme = preload("res://src/Themes/Buttons/SidebarButtonsUnpressed.tres")
const OptionPressed : Theme = preload("res://src/Themes/Buttons/SidebarButtonsPressed.tres")

#CONSTANTS
const ICON_SIZE : int = 25

#VARIABLES
var CurrentOptionIdx : int = 0

#Ignores the Same option selection on indexes set to true
var ignores : PoolByteArray = [false,true,false,true,false,false,false,false,false,false]
var OptionTitles : PoolStringArray = [
	"All Songs",
	"Playlists",
	"Folders", 
	"Artists", 
	"Change Tags", 
	"Download", 
	"Lyrics", 
	"Stats", 
	"Settings", 
	"Infos"
]
var OptionIcons : PoolStringArray = [
	"res://src/Assets/Icons/White/Audio/MusicNotes/music_72px.png",
	"res://src/Assets/Icons/White/General/list_72px.png",
	"res://src/Assets/Icons/White/Folder/add folder_72px.png",
	"res://src/Assets/Icons/White/Users/group_72px.png",
	"res://src/Assets/Icons/White/Tagging/cd_72px.png",
	"res://src/Assets/Icons/White/Download/download_72px.png",
	"res://src/Assets/Icons/White/General/middle alignment_72px.png",
	"res://src/Assets/Icons/White/Stats/bar chart_72px.png",
	"res://src/Assets/Icons/White/Settings/settings_72px.png",
	"res://src/Assets/Icons/White/General/information_72px.png"
]


func _ready():
	#Ignoring the first and last child -> Spacers
	for i in OptionTitles.size():
		var NewSidebarOption : Control = load("res://src/Scenes/Main/SidebarOption.tscn").instance()
		self.add_child(NewSidebarOption)
		self.move_child(NewSidebarOption,i)
		#Init Option
		NewSidebarOption.OptionIcon.rect_min_size.x = ICON_SIZE
		NewSidebarOption.OptionIcon.set_texture(load(OptionIcons[i]))
		NewSidebarOption.OptionLabel.set_text(OptionTitles[i])
		if NewSidebarOption.connect("pressed",self,"OnOptionPressed",[i]):
			Global.root.Message("CONNECTING OPTION BUTTONS ON MAIN",  SaveData.MESSAGE_ERROR)
	ToggleIcons(false)
	self.get_child(CurrentOptionIdx).theme = OptionPressed


func OnOptionPressed(var idx : int):
	set_sidebar_option(idx)
	Global.root.LoadOptions(idx, ignores[idx])


func set_sidebar_option(var idx : int):
	self.get_child(CurrentOptionIdx).theme = OptionUnpressed
	CurrentOptionIdx = idx
	self.get_child(CurrentOptionIdx).theme = OptionPressed


func ToggleIcons(var toggle : bool) -> void:
	for i in OptionTitles.size():
		self.get_child(i).OptionLabel.set_visible(!toggle)
		self.get_child(i).OptionIcon.set_visible(toggle)

