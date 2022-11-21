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

onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var image_view_cover : TextureButton = $VBoxContainer/HBoxContainer/Cover
onready var middle_part : MarginContainer = get_parent()
onready var option_vbox : VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options
onready var option_place : MarginContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options/OptionPlace
onready var background_panel : PanelContainer = $DynamicBackground
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
	anim_player.play("start")
	if self.connect("resized",self,"on_ImageView_resized"):
		Global.root.message("CANNOT CONNECT IMAGE VIEW TO RESIZED FUNCTION", SaveData.MESSAGE_ERROR)
	on_ImageView_resized()


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewLastOption", last_option_idx)
	Global.root.toggle_songlist_input(true)


#end function plays the appear funtion backwards and removes scene when finished
func end() -> void:
	anim_player.play_backwards("start")
	yield(anim_player,"animation_finished")
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
			background_panel.set_material( load("res://src/Ressources/Shaders/DirectionalFadeWithColor.tres") )
			var bg_clr : Color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewStandardBackgroundColor")
			background_panel.material.set_shader_param("color", bg_clr)
		2:
			background_panel.set_material( load("res://src/Ressources/Shaders/DirectionalFadeWithColor.tres") )
			
			# retrieving the data of the current Cover Texture, resizing to 1x1
			# and the Setting the background_panel to the Color of this one pixel
			var cover_img : Image = image_view_cover.get_normal_texture().get_data()
			cover_img.resize(1,1,1)
			cover_img.lock()
			var tw : SceneTreeTween = create_tween()
			var _tw : PropertyTweener = tw.tween_property(
				background_panel.material,
				"shader_param/color",
				cover_img.get_pixel(0,0),
				0.4
			)


func _on_Lyrics_pressed():
	free_current_option()
	add_option(ImageViewOptions.LYRICS)


func UpdateOption() -> void:
	# updates the Current Image View Option
	# called when the Song has been Changed
	for Option in option_place.get_children():
		if Option.has_method("update"):
			Option.update()


func add_option(var option_idx : int) -> void:
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
		free_current_option()
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
				duration
			)
			middle_buffer.hide()
			option_header.set_visible(false)
			yield(tw,"finished")
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
			#option_place.get_parent().modulate.a = 1.0
			add_option(last_option_idx)
			option_header.set_visible(true)
			left_buffer.set_h_size_flags(SIZE_FILL)
		
		is_cover_resizing = false
		# so that cover get resized correctly
		on_ImageView_resized()
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused", toggle)


func _on_Cover_pressed():
	toggle_cover_focus(!is_cover_focused)


func _on_Infos_pressed():
	free_current_option()
	add_option(ImageViewOptions.INFOS)
