extends PanelContainer

var context : String = "User Selection"

onready var profile_img : TextureRect = $HBoxContainer/ProfileImg
onready var load_user_select : Button = $LoadUserSelect
onready var username_label : Label = $HBoxContainer/Username

func _ready():
	init_profile_box()


func init_profile_box():
	Modulator.init_modulation(self)
	if Global.current_profile_idx != -1:
		var username : String = Global.user_profiles[Global.current_profile_idx]
		username_label.set_text(username)
		profile_img.texture = ImageLoader.resize_texture(
			ImageLoader.get_cover("user://GlobalSettings/UserImages/" + username + ".png", ImageLoader.ImageTypes.USER_PROFILE),
			profile_img.rect_size
		)

