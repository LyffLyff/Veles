extends PanelContainer

#NODES
onready var ProfileImage : TextureRect = $HBoxContainer/ProfileImg
onready var LoadUserSelect : Button = $LoadUserSelect
onready var UsernameLabel : Label = $HBoxContainer/Username


func _ready():
	InitProfileBox()


func InitProfileBox():
	if Global.current_profile_idx != -1:
		var Username : String = Global.user_profiles[Global.current_profile_idx]
		UsernameLabel.set_text(Username)
		ProfileImage.set_texture( ImageLoader.get_cover("user://GlobalSettings/UserImages/" + Username + ".png") )
