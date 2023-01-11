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
onready var options : TextureButton = $VBoxContainer/Options/Options


func _ready():
	var _err : int = play.connect("mouse_entered", Modulator, "modulate_hover", [play])
	_err = play.connect("mouse_exited", Modulator, "modulate_normal", [play])
	_err = play.connect("pressed", Modulator, "modulate_pressed", [play])
	_err = options.connect("pressed", self.get_owner(), "init_playlist_options", [options])


func set_header_cover(var new_cover : Texture) -> void:
	header_cover.texture = new_cover
	background_cover.texture = new_cover
