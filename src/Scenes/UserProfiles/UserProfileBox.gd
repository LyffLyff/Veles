extends PanelContainer

#NODES
onready var ProfileImage : TextureRect = $HBoxContainer/ProfileImg
onready var LoadUserSelect : Button = $LoadUserSelect
onready var UsernameLabel : Label = $HBoxContainer/Username


func _ready():
	InitProfileBox()


func InitProfileBox():
	if Global.CurrentProfileIdx != -1:
		var Username : String = Global.UserProfiles[Global.CurrentProfileIdx]
		UsernameLabel.set_text(Username)
		ProfileImage.set_texture( ImageLoader.GetCover("user://GlobalSettings/UserImages/" + Username + ".png") )
