extends Control


#CONSTANTS
const OptionsScenes : Array = [
	"res://src/Scenes/SubOptions/Lyrics/LyricScroller.tscn",
	"res://src/Scenes/Views/SongInfos.tscn"
]

#ENUMS
enum ImageViewOptions {
	LYRICS,
	INFOS
}

#NODES
onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var ImageViewCover : TextureButton = $VBoxContainer/HBoxContainer/Cover
onready var middle_part : MarginContainer = get_parent()
onready var Options : VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options
onready var OptionsPlace : MarginContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options/OptionPlace
onready var Background : PanelContainer = $DynamicBackground
onready var MiddleBuffer : Control = $VBoxContainer/HBoxContainer/MiddleBuffer
onready var LeftBuffer : Control = $VBoxContainer/HBoxContainer/Buffer
onready var LeftEmpty : Control = $VBoxContainer/HBoxContainer/LeftEmpty
onready var OptionHeader : HBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Option/Options/HBoxContainer
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
 
#VARIABLES
var ROUNDING_MULTIPLE : int = 16
const TOP_SPACING : int = 100
const UNFOCUSED_COVER_MAX_PERCENT : int = 40
var CoverFocused : bool = false
var CoverCurrentlyResizing : bool = false
var LastOption : int = 0



func _ready():
	Options.get_parent().get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewOption")
	)
	LastOption = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewLastOption")
	ToggleFocusCover( SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused"), 0.0 )
	SetImageViewBackgroundColor()
	anim_player.play("start")
	if self.connect("resized",self,"OnImageViewResized"):
		Global.root.message("CANNOT CONNECT IMAGE VIEW TO RESIZED FUNCTION", SaveData.MESSAGE_ERROR)
	OnImageViewResized()


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewLastOption", LastOption)
	Global.root.toggle_songlist_input(true)


#end function plays the appear funtion backwards and removes scene when finished
func end() -> void:
	anim_player.play_backwards("start")
	yield(anim_player,"animation_finished")
	self.queue_free()


func OnImageViewResized():
	ImageViewCover.rect_min_size = GetUnfocusedCoverSize()


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
			#var BackgroundTile : ImageTexture = ImageTexture.new()
			#var Img : Image = ImageViewCover.get_normal_texture().get_data()
			#BackgroundTile.create_from_image(Img,Texture.FLAGS_DEFAULT)
			Background.set_material( load("res://src/Ressources/Shaders/StarShader.tres") )
			#Background.material.set_shader_param("pattern",BackgroundTile)
		1:
			Background.set_material( load("res://src/Ressources/Shaders/DirectionalFadeWithColor.tres") )
			var BackgroundClr : Color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewStandardBackgroundColor")
			Background.material.set_shader_param("color", BackgroundClr)
		2:
			Background.set_material( load("res://src/Ressources/Shaders/DirectionalFadeWithColor.tres") )
			
			#retrieving the data of the current Cover Texture, resizing to 1x1
			#and the Setting the Background to the Color of this one pixel
			var CoverImage : Image = ImageViewCover.get_normal_texture().get_data()
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
		if Option.has_method("Update"):
			Option.Update()


func AddOption(var OptionIdx : int) -> void:
	OptionHeader.get_child( LastOption + 1 ).theme = load("res://src/Themes/Buttons/SidebarButtonsUnpressed.tres")
	LastOption = OptionIdx
	OptionHeader.get_child( LastOption + 1 ).theme = load("res://src/Themes/Buttons/SidebarButtonsPressed.tres")
	var NewOption : Control = load(OptionsScenes[OptionIdx]).instance()
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
	if !CoverCurrentlyResizing:
		CoverCurrentlyResizing = true
		CoverFocused = Focus
		FreeOption()
		var tw : SceneTreeTween = create_tween()
		tw = tw.set_trans(Tween.TRANS_QUAD)
		if Focus:
			var _tw : PropertyTweener = tw.tween_property(
				ImageViewCover,
				"rect_position:x",
				(OS.get_window_size().x / 2.0) - (ImageViewCover.rect_size.x / 2.0),
				Duration
			)
			_tw = tw.parallel().tween_property(
				Options.get_parent(),
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
				ImageViewCover,
				"rect_position:x",
				20.0,
				Duration
			)
			MiddleBuffer.show()
			yield(tw,"finished")
			_tw = create_tween().tween_property(
				Options.get_parent(),
				"modulate:a",
				1.0,
				Duration
			)
			#Options.get_parent().modulate.a = 1.0
			AddOption(LastOption)
			OptionHeader.set_visible(true)
			LeftBuffer.set_h_size_flags(SIZE_FILL)
		
		CoverCurrentlyResizing = false
		#So that cover get resized correctly
		OnImageViewResized()
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused", Focus)


func OnImageViewCoverPressed():
	ToggleFocusCover(!CoverFocused)


func OnInfosPressed():
	FreeOption()
	AddOption(ImageViewOptions.INFOS)
