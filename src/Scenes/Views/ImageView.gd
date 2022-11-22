extends Control
# Image View describes the Menu that overlays over the main scene,
# that has the files cover, lyrics and infos in the focus

enum ImageViewOptions {
	LYRICS,
	INFOS,
}

const TOP_SPACING : int = 100
const UNFOCUSED_COVER_MAX_PERCENT : int = 40
const ROUNDING_MULTIPLE : int = 16
const OPTION_SCENES : Array = [
	"res://src/Scenes/SubOptions/Lyrics/LyricScroller.tscn",
	"res://src/Scenes/Views/SongInfos.tscn"
]

var is_cover_focused : bool = false
var is_cover_resizing : bool = false
var last_option_idx : int = 0

onready var image_view_cover : TextureButton = $VBoxContainer/HBoxContainer/Cover
onready var middle_part : MarginContainer = get_parent()
onready var option_vbox : VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options
onready var option_place : MarginContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options/OptionPlace
onready var background_panel : PanelContainer = $DynamicBackground
onready var static_bg : PanelContainer = $StaticBackground
onready var middle_buffer : Control = $VBoxContainer/HBoxContainer/MiddleBuffer
onready var left_buffer : Control = $VBoxContainer/HBoxContainer/Buffer
onready var option_header : HBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options/HBoxContainer

func _ready():
	option_vbox.get_parent().get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewOption")
	)
	last_option_idx = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewLastOption")
	toggle_cover_focus( SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused"), 0.0 )
	set_image_view_bg_clr()
	#start anima
	if self.connect("resized",self,"on_ImageView_resized"):
		Global.root.message("CANNOT CONNECT IMAGE VIEW TO RESIZED FUNCTION", SaveData.MESSAGE_ERROR)
	var _tw = init_image_view(true)
	on_ImageView_resized()


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewLastOption", last_option_idx)
	Global.root.toggle_songlist_input(true)


func init_image_view(var toggle : bool) -> SceneTreeTween:
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_QUAD)
	tw = tw.set_ease(Tween.EASE_IN)
	var _ptw : PropertyTweener = tw.tween_property(
		static_bg,
		"modulate:a",
		1.0 * int(toggle),
		0.3
	)
	_ptw = tw.parallel().tween_property(
		image_view_cover,
		"self_modulate:a",
		1.0 * int(toggle),
		0.4
	)
	_ptw = tw.parallel().tween_property(
		background_panel,
		"modulate:a",
		1.0 * int(toggle),
		0.5
	)
	_ptw = tw.parallel().tween_property(
		option_vbox,
		"modulate:a",
		1.0 * int(toggle),
		0.5
	)
	return tw


func exit_image_view() -> void:
	yield(init_image_view(0.0),"finished")
	self.queue_free()


func on_ImageView_resized():
	image_view_cover.rect_min_size = get_unfocused_cover_size()


func get_unfocused_cover_size() -> Vector2:
	var new_cover_size : Vector2 = Vector2()
	new_cover_size.y = middle_part.rect_size.y - TOP_SPACING
	new_cover_size.x = OS.get_window_size().x * UNFOCUSED_COVER_MAX_PERCENT / 100.0
	if new_cover_size.x > new_cover_size.y:
		new_cover_size.x = new_cover_size.y
	return new_cover_size


func set_image_view_bg_clr() -> void:
	match SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ImageViewBackground"):
		0:
			background_panel.set_material(load("res://src/Ressources/Shaders/StarShader.tres"))
		1:
			background_panel.set_material(load("res://src/Ressources/Shaders/direction_fade.tres"))
			var bg_clr : Color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewStandardBackgroundColor")
			background_panel.material.set_shader_param("color", bg_clr)
		2:
			background_panel.set_material(load("res://src/Ressources/Shaders/direction_fade.tres"))
			
			# retrieving the data of the current Cover Texture, resizing to 1x1
			# and the Setting the background_panel to the Color of this one pixel
			var cover_img : Image = image_view_cover.get_normal_texture().get_data()
			cover_img.resize(1,1,1)
			cover_img.lock()
			
			var tw : SceneTreeTween = create_tween()
			var _ptw : PropertyTweener = tw.tween_property(
				background_panel.material,
				"shader_param/color",
				cover_img.get_pixel(0,0),
				0.3
			)

func update_option() -> void:
	# updates the Current Image View Option
	# called when the Song has been Changed
	for option in option_place.get_children():
		if option.has_method("update"):
			option.update()


func add_option(var option_idx : int) -> void:
	free_current_option()
	option_header.get_child( last_option_idx + 1 ).theme = load("res://src/Themes/Buttons/SidebarButtonsUnpressed.tres")
	last_option_idx = option_idx
	option_header.get_child( last_option_idx + 1 ).theme = load("res://src/Themes/Buttons/SidebarButtonsPressed.tres")
	var new_option : Control = load(OPTION_SCENES[option_idx]).instance()
	option_place.add_child(new_option)
	new_option.modulate.a = 0.0
	var _ptw : PropertyTweener = create_tween().tween_property(
		new_option,
		"modulate:a",
		1.0,
		0.3
	)


func free_current_option() -> void:
	for option in option_place.get_children():
		option.queue_free()


func toggle_cover_focus(var toggle : bool, var duration : float = 0.3) -> void:
	if !is_cover_resizing:
		is_cover_resizing = true
		is_cover_focused = toggle
		var tw : SceneTreeTween = create_tween()
		tw = tw.set_trans(Tween.TRANS_QUAD)
		if toggle:
			var _tw : PropertyTweener = tw.tween_property(
				image_view_cover,
				"rect_position:x",
				(OS.get_window_size().x / 2.0) - (image_view_cover.rect_size.x / 2.0),
				duration
			)
			_tw = tw.parallel().tween_property(
				option_vbox.get_parent(),
				"modulate:a",
				0.0,
				duration / 2
			)
			middle_buffer.hide()
			yield(tw,"finished")
			option_header.set_visible(false)
			left_buffer.set_h_size_flags(SIZE_EXPAND_FILL)
		else:
			var _tw : PropertyTweener = tw.tween_property(
				image_view_cover,
				"rect_position:x",
				20.0,
				duration
			)
			middle_buffer.show()
			yield(tw,"finished")
			_tw = create_tween().tween_property(
				option_vbox.get_parent(),
				"modulate:a",
				1.0,
				duration
			)
			add_option(last_option_idx)
			option_header.set_visible(true)
			left_buffer.set_h_size_flags(SIZE_FILL)
		
		is_cover_resizing = false
		# so that cover get resized correctly
		on_ImageView_resized()
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused", toggle)


func _on_Lyrics_pressed():
	add_option(ImageViewOptions.LYRICS)


func _on_Cover_pressed():
	toggle_cover_focus(!is_cover_focused)


func _on_Infos_pressed():
	add_option(ImageViewOptions.INFOS)
