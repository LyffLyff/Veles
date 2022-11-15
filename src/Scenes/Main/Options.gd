extends VBoxContainer
# a script that handles the initialising and animations of the sidebars options

const ICON_SIZE : int = 25
const option_unpressed : Theme = preload("res://src/Themes/Buttons/SidebarButtonsUnpressed.tres")
const option_pressed : Theme = preload("res://src/Themes/Buttons/SidebarButtonsPressed.tres")

var current_option_idx : int = 0
# ignores the Same option selection on indexes set to true
var ignores : PoolByteArray = [false,true,false,true,false,false,false,false,false,false]
var option_titles : PoolStringArray = [
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
var option_icons : PoolStringArray = [
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
	# ignoring the first and last child -> Spacers
	for i in option_titles.size():
		
		var new_option : Control = load("res://src/Scenes/Main/SidebarOption.tscn").instance()
		self.add_child(new_option)
		self.move_child(new_option,i)
		
		# init option
		new_option.option_icon.rect_min_size.x = ICON_SIZE
		new_option.option_icon.set_texture(load(option_icons[i]))
		new_option.option_label.set_text(option_titles[i])
		if new_option.connect("pressed",self,"on_option_pressed",[i]):
			Global.root.message("CONNECTING OPTION BUTTONS ON MAIN",  SaveData.MESSAGE_ERROR)
	toggle_icons(false)
	self.get_child(current_option_idx).theme = option_pressed


func on_option_pressed(var idx : int):
	Global.root.load_option(idx, ignores[idx])


func set_sidebar_option(var idx : int):
	self.get_child(current_option_idx).theme = option_unpressed
	current_option_idx = idx
	self.get_child(current_option_idx).theme = option_pressed


func toggle_icons(var toggle : bool) -> void:
	for i in option_titles.size():
		self.get_child(i).option_label.set_visible(!toggle)
		self.get_child(i).option_icon.set_visible(toggle)

