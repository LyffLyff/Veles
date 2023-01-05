extends PanelContainer

onready var title_label : Label = $VBoxContainer/HeaderContent/VBoxContainer/Labels/Title
onready var creation_date_label : Label = $VBoxContainer/HeaderContent/VBoxContainer/Labels/Created
onready var playlist_duration_label : Label = $VBoxContainer/HeaderContent/VBoxContainer/Labels/Length
onready var song_amount_label : Label = $VBoxContainer/HeaderContent/VBoxContainer/Labels/Amount
onready var header_cover : TextureRect = $VBoxContainer/HeaderContent/Cover
onready var background_cover : TextureRect = $BackgroundTexture
onready var description : Control = $VBoxContainer/HeaderContent/VBoxContainer/Description
onready var bottom_blur : Panel = $BottomBlur


func _ready():
	self.get_stylebox("panel").bg_color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "PlaylistHeader")


func set_header_cover(var new_cover : Texture) -> void:
	header_cover.texture = new_cover
	background_cover.texture = new_cover
