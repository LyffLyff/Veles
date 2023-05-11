extends "res://src/Scenes/General/SonglistBlocker.gd"

signal image_view_exit_started
signal init_tween_started
signal init_tween_ended

const COVER_X_PERCENTAGE : int = 50
const COVER_Y_PERCENTAGE : int = 90
const COVER_SWITCHER_MIN_Y : int = 40
const OPTION_SCENES : Array = [
	"res://src/Scenes/SubOptions/Lyrics/LyricScroller.tscn",
	"res://src/Scenes/Views/ImageView/Options/SongInfos.tscn"
]

var is_cover_focused : bool = false
var is_cover_resizing : bool = false
var last_option_idx : int = -1

onready var option_controller : MarginContainer = $HBoxContainer/OptionController
onready var option_container : MarginContainer = $HBoxContainer/OptionController/OptionBg/VBoxContainer/OptionContainer
onready var option_header : HBoxContainer = $HBoxContainer/OptionController/OptionBg/VBoxContainer/ImageViewHeader
onready var option_bg : PanelContainer = $HBoxContainer/OptionController/OptionBg
onready var image_view_cover : Control = $HBoxContainer/ImageViewCover
onready var fading_bg : PanelContainer = $FadingBackground
onready var left_buffer : Control = $HBoxContainer/LeftEmpty

func _ready():
	yield(init_image_view(true), "finished")
	Global.root.call_deferred("toggle_songlist_visibility", false)


func _exit_tree():
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewLastOption", last_option_idx)


func init_image_view(var entry : bool) -> PropertyTweener:
	# connect option buttons
	if entry:
		# init values on entry
		var _err : int = image_view_cover.connect("cover_updated", self, "init_background", [], CONNECT_ONESHOT)
		_err = Global.connect("window_resize_ended", self, "sharpen_image_view_cover")
		image_view_cover.cover.connect("pressed", self, "_on_ImageViewCover_pressed")
		last_option_idx = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewLastOption")
		option_bg.get_stylebox("panel").bg_color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewOption")
		self.modulate.a = 0.0
		
		# init options
		self.sharpen_image_view_cover()
		self._on_NewImageView_resized()
		self.toggle_cover_focus(SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused"), 0.0)
		_err = option_header.connect("option_selected", self, "load_option")
		self.load_option(last_option_idx + 1)
		
		self.emit_signal("init_tween_started")
	
	# animation
	Global.request_fps_change(60)
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	var ptw : PropertyTweener = tw.tween_property(self, "modulate:a", float(entry), 0.4)
	var _err : int = ptw.connect("finished", self, "emit_signal", ["init_tween_ended"])
	_err = ptw.connect("finished", Global, "request_fps_change", [4])
	return ptw


func exit_image_view() -> void:
	emit_signal("image_view_exit_started")
	Global.root.call_deferred("toggle_songlist_visibility", true)
	yield(init_image_view(0.0), "finished")
	self.queue_free()


func init_background(var duration : float = 0.5) -> void:
	var background_tw : SceneTreeTween = get_tree().create_tween()
	var ptw : PropertyTweener
	background_tw = background_tw.set_trans(Tween.TRANS_QUAD)
	match SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ImageViewBackground"):
		
		0:
			# Stars 
			var star_shader : ShaderMaterial = load("res://src/Ressources/Shaders/StarShader.tres")
			fading_bg.material = star_shader
			fading_bg.self_modulate.a = 0.0
		
		1:
			# Fixed Color
			fading_bg.material = null
			fading_bg.get_stylebox("panel").bg_color = SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "ImageViewStandardBackgroundColor")
		
		2:
			# Auto Color
			var directional_fade : ShaderMaterial = load("res://src/Ressources/Shaders/directional_fade.tres")
			fading_bg.material = directional_fade
			
			# set automatic color
			fading_bg.material.set_shader_param("color", image_view_cover.get_center_color())
			
			ptw = background_tw.tween_property(
				fading_bg.material,
				"shader_param/strength",
				2.0,
				duration
			)
	
	ptw = background_tw.parallel().tween_property(
		fading_bg,
		"self_modulate:a",
		1.0,
		duration
	)
	
	var _err : int = image_view_cover.connect("cover_updated", self, "update_background")
	_err = image_view_cover.connect("cover_updated", self, "sharpen_image_view_cover")


func update_background() -> void:
	# tweening to color of new cover if cover has changed
	match SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ImageViewBackground"):
		0:
			pass
		1:
			pass
		2:
			var new_clr : Color = image_view_cover.get_center_color()
			if !new_clr.is_equal_approx(fading_bg.material.get("shader_param/color")):
				Global.request_fps_change(60)
				var tw : SceneTreeTween = get_tree().create_tween()
				tw = tw.set_trans(Tween.TRANS_QUAD)
				var ptw : PropertyTweener = tw.tween_property(
					fading_bg.material,
					"shader_param/color",
					new_clr,
					0.75
				)
				var _err : int = ptw.connect("finished", Global,"request_fps_change", [4])
			else:
				pass
				#print("SIMILAR")


func toggle_cover_focus(var focus_cover : bool, var duration : float = 0.3) -> void:
	# set values
	is_cover_focused = focus_cover
	is_cover_resizing = true
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewCoverFocused", is_cover_focused)
	
	# prepare tweens
	var dst : float
	if is_cover_focused:
		dst = get_cover_center_horizontal()
	else:
		dst = 20.0
		option_bg.modulate.a = 0.0
		option_bg.show()
	
	# animations
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_QUAD)
	
	var ptw_option : PropertyTweener = tw.tween_property(
		left_buffer,
		"rect_min_size:x",
		dst,
		duration
	)
	var ptw_option_bg : PropertyTweener = tw.parallel().tween_property(
		option_bg,
		"modulate:a",
		float(!is_cover_focused),
		duration
	)
	
	if is_cover_focused:
		var _err : int = ptw_option.connect("finished", option_bg, "set_visible", [!is_cover_focused])


func get_cover_center_horizontal() -> int:
	return int((self.rect_size.x / 2) - (image_view_cover.cover.rect_min_size.x / 2))


func get_image_view_cover_size() -> Vector2:
	var new_cover_size : Vector2 = Vector2()
	new_cover_size.y = get_fixed_cover_size((int(self.rect_size.y) * COVER_Y_PERCENTAGE / 100) - COVER_SWITCHER_MIN_Y) 
	new_cover_size.x = get_fixed_cover_size(int(self.rect_size.x) * COVER_X_PERCENTAGE / 100)
	if new_cover_size.x > new_cover_size.y:
		new_cover_size.x = new_cover_size.y
	return new_cover_size


func get_fixed_cover_size(var proposed_width : int) -> float:
	# always rounds the given length to an even value
	# odd values may cause a "glitched" line of pixels at the bottom of the image
	return float(proposed_width + int(proposed_width % 2 == 0))


func sharpen_image_view_cover() -> void:
	# resizes the image to the size of the actual container making it look way sharper
	# waits for the two frames so all rect_sizes will have changed by then
	# will only be called at the end of resizing, since it costs much processing power
	for i in 2: yield(get_tree(), "idle_frame")
	if Global.root.player.current_cover_idx == -1:
		return
	var original_texture : Texture = Global.root.player.current_covers[Global.root.player.current_cover_idx]
	var image_loader : ImageLoader = ImageLoader.new()
	var new_size : Vector2
	
	# smaller value, either on the x or y axis defines the size of the image
	if self.image_view_cover.cover.rect_size.y < self.image_view_cover.cover.rect_size.x:
		new_size = Vector2(self.image_view_cover.cover.rect_size.y, self.image_view_cover.cover.rect_size.y)
	else:
		new_size = Vector2(self.image_view_cover.cover.rect_size.x, self.image_view_cover.cover.rect_size.x)
	
	self.image_view_cover.cover.texture_normal = image_loader.resize_texture(
		original_texture,
		new_size
	)


func load_option(var option_idx : int) -> void:
	free_current_option()
	if option_idx == 0:
		toggle_cover_focus(true)
	else:
		last_option_idx = option_idx - 1
		var new_option : Control = load(OPTION_SCENES[last_option_idx]).instance()
		option_container.add_child(new_option)
		new_option.modulate.a = 0.0
		var _ptw : PropertyTweener = create_tween().tween_property(
			new_option,
			"modulate:a",
			1.0,
			0.3
		)


func free_current_option() -> void:
	for option in option_container.get_children():
		option.queue_free()


func update_option() -> void:
	# updates the Current Image View Option
	# called when the Song has been Changed
	for option in option_container.get_children():
		if option.has_method("update"):
			option.update()


func _on_ImageViewCover_pressed():
	toggle_cover_focus(!is_cover_focused)


func _on_NewImageView_resized():
	if image_view_cover:
		var min_size : Vector2 = get_image_view_cover_size()
		image_view_cover.cover.rect_min_size = min_size
		if is_cover_focused:
			left_buffer.rect_min_size.x = get_cover_center_horizontal()
