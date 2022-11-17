extends Control
# Image View describes the Menu that overlays over the main scene,
# that has the files cover, lyrics and infos in the focus

const TOP_SPACING : int = 100
const UNFOCUSED_COVER_MAX_PERCENT : int = 40
const ROUNDING_MULTIPLE : int = 16
const OPTION_SCENES : Array = [
	"res://src/Scenes/SubOptions/Lyrics/LyricScroller.tscn",
	"res://src/Scenes/Views/SongInfos.tscn"
]
enum ImageViewOptions {
	LYRICS,
	INFOS,
}

var is_cover_focused : bool = false
var is_cover_resizing : bool = false
var last_option_idx : int = 0

onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var image_view_cover : TextureButton = $VBoxContainer/HBoxContainer/Cover
onready var middle_part : MarginContainer = get_parent()
onready var option_place : VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options
onready var OptionsPlace : MarginContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options/OptionPlace
onready var Background : PanelContainer = $DynamicBackground
onready var MiddleBuffer : Control = $VBoxContainer/HBoxContainer/MiddleBuffer
onready var LeftBuffer : Control = $VBoxContainer/HBoxContainer/Buffer
onready var LeftEmpty : Control = $VBoxContainer/HBoxContainer/LeftEmpty
onready var OptionHeader : HBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options/HBoxContainer

func _ready():
	option_place.get_parent().get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewOption")
	)
	last_option_idx = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewLastOption")
	ToggleFocusCover( SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused"), 0.0 )
	SetImageViewBackgroundColor()
	anim_player.play("start")
	if self.connect("resized",self,"OnImageViewResized"):
		Global.root.message("CANNOT CONNECT IMAGE VIEW TO RESIZED FUNCTION", SaveData.MESSAGE_ERROR)
	OnImageViewResized()


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


func OnImageViewResized():
	image_view_cover.rect_min_size = GetUnfocusedCoverSize()


func GetUnfocusedCoverSize() -> Vector2:
	var NewRectCoverSize : Vector2 = Vector2()
	NewRectCoverSize.y = middle_part.rect_size.y - TOP_SPACING
	NewRectCoverSize.x = OS.get_window_size().x * UNFOCUSED_COVER_MAX_PERCENT / 100.0
	if NewRectCoverSize.x > NewRectCoverSize.y:
		NewRectCoverSize.x = NewRectCoverSize.y
	return NewRectCoverSize


func SetImageViewBackgroundColor() -> void:
	match SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ImageViewBackground"):
		0:
			Background.set_material(load("res://src/Ressources/Shaders/StarShader.tres"))
		1:
			Background.set_material( load("res://src/Ressources/Shaders/DirectionalFadeWithColor.tres") )
			var BackgroundClr : Color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewStandardBackgroundColor")
			Background.material.set_shader_param("color", BackgroundClr)
		2:
			Background.set_material( load("res://src/Ressources/Shaders/DirectionalFadeWithColor.tres") )
			
			#retrieving the data of the current Cover Texture, resizing to 1x1
			#and the Setting the Background to the Color of this one pixel
			var CoverImage : Image = image_view_cover.get_normal_texture().get_data()
			CoverImage.resize(1,1,1)
			CoverImage.lock()
			var ColorTween : SceneTreeTween = create_tween()
			var _tw : PropertyTweener = ColorTween.tween_property(
				Background.material,
				"shader_param/color",
				CoverImage.get_pixel(0,0),
				0.4
			)


func OnLyricsPressed():
	FreeOption()
	AddOption(ImageViewOptions.LYRICS)


func UpdateOption() -> void:
	#Updates the Current Image View Option
	#Called when the Song has been Changed
	for Option in OptionsPlace.get_children():
		if Option.has_method("update"):
			Option.update()


func AddOption(var OptionIdx : int) -> void:
	OptionHeader.get_child( last_option_idx + 1 ).theme = load("res://src/Themes/Buttons/SidebarButtonsUnpressed.tres")
	last_option_idx = OptionIdx
	OptionHeader.get_child( last_option_idx + 1 ).theme = load("res://src/Themes/Buttons/SidebarButtonsPressed.tres")
	var NewOption : Control = load(OPTION_SCENES[OptionIdx]).instance()
	OptionsPlace.add_child( NewOption )
	NewOption.modulate.a = 0.0
	var _ptw : PropertyTweener = create_tween().tween_property(
		NewOption,
		"modulate:a",
		1.0,
		0.3
	)


func FreeOption() -> void:
	for Option in OptionsPlace.get_children():
		Option.queue_free()


func ToggleFocusCover(var Focus : bool, var Duration : float = 0.3) -> void:
	if !is_cover_resizing:
		is_cover_resizing = true
		is_cover_focused = Focus
		FreeOption()
		var tw : SceneTreeTween = create_tween()
		tw = tw.set_trans(Tween.TRANS_QUAD)
		if Focus:
			var _tw : PropertyTweener = tw.tween_property(
				image_view_cover,
				"rect_position:x",
				(OS.get_window_size().x / 2.0) - (image_view_cover.rect_size.x / 2.0),
				Duration
			)
			_tw = tw.parallel().tween_property(
				option_place.get_parent(),
				"modulate:a",
				0.0,
				Duration
			)
			MiddleBuffer.hide()
			OptionHeader.set_visible(false)
			yield(tw,"finished")
			LeftBuffer.set_h_size_flags(SIZE_EXPAND_FILL)
		else:
			var _tw : PropertyTweener = tw.tween_property(
				image_view_cover,
				"rect_position:x",
				20.0,
				Duration
			)
			MiddleBuffer.show()
			yield(tw,"finished")
			_tw = create_tween().tween_property(
				option_place.get_parent(),
				"modulate:a",
				1.0,
				Duration
			)
			#option_place.get_parent().modulate.a = 1.0
			AddOption(last_option_idx)
			OptionHeader.set_visible(true)
			LeftBuffer.set_h_size_flags(SIZE_FILL)
		
		is_cover_resizing = false
		# so that cover get resized correctly
		OnImageViewResized()
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused", Focus)


func OnImageViewCoverPressed():
	ToggleFocusCover(!is_cover_focused)


func OnInfosPressed():
	FreeOption()
	AddOption(ImageViewOptions.INFOS)
