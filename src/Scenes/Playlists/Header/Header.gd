extends PanelContainer

onready var title_label : Label = $VBoxContainer/HeaderContent/VBoxContainer/Labels/Title
onready var creation_date_label : Label = $VBoxContainer/HeaderContent/VBoxContainer/Labels/Created
onready var playlist_duration_label : Label = $VBoxContainer/HeaderContent/VBoxContainer/Labels/Length
onready var song_amount_label : Label = $VBoxContainer/HeaderContent/VBoxContainer/Labels/Amount
onready var header_cover : TextureRect = $VBoxContainer/HeaderContent/Cover
onready var background_cover : TextureRect = $BackgroundTexture
onready var description : Control = $VBoxContainer/HeaderContent/VBoxContainer/Description
onready var bottom_blur : Panel = $BottomBlur
onready var play : TextureButton = $VBoxContainer/Options/Play
onready var shuffle : TextureButton = $VBoxContainer/Options/Shuffle
onready var queue : TextureButton = $VBoxContainer/Options/Queue
onready var options : TextureButton = $VBoxContainer/Options/Options


func _ready():
	bottom_blur.material.set_shader_param("color", 
		SettingsData.get_setting(
			SettingsData.DESIGN_SETTINGS,
			"MainBackgroundColor"
		)
	)
	
	var _err : int = play.connect("mouse_entered", Modulator, "modulate_hover", [play])
	_err = play.connect("mouse_exited", Modulator, "modulate_normal", [play])
	_err = play.connect("pressed", Modulator, "modulate_pressed", [play])
	_err = options.connect("mouse_entered", Modulator, "modulate_hover", [options])
	_err = options.connect("mouse_exited", Modulator, "modulate_normal", [options])
	_err = options.connect("pressed", Modulator, "modulate_pressed", [options])
	_err = shuffle.connect("mouse_entered", Modulator, "modulate_hover", [shuffle])
	_err = shuffle.connect("mouse_exited", Modulator, "modulate_normal", [shuffle])
	_err = shuffle.connect("pressed", Modulator, "modulate_pressed", [shuffle])
	_err = queue.connect("mouse_entered", Modulator, "modulate_hover", [queue])
	_err = queue.connect("mouse_exited", Modulator, "modulate_normal", [queue])
	_err = queue.connect("pressed", Modulator, "modulate_pressed", [queue])
	_err = options.connect("pressed", self.get_owner(), "init_playlist_options", [options])


func set_header_cover(var new_cover : Texture) -> void:
	header_cover.texture = ImageLoader.resize_texture(new_cover, Vector2(header_cover.rect_size.y, header_cover.rect_size.y))
	background_cover.texture = new_cover
