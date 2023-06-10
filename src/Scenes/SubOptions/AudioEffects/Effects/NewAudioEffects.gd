extends Control

const PLUS_TEXTURE : StreamTexture = preload("res://src/assets/Icons/White/General/Plus128px.png")
const MINUS_TEXTURE : StreamTexture = preload("res://src/assets/Icons/White/General/Minus128px.png")
const shrinked_y : float = 30.0
const tw_speed : float = 550.0

var effect_idx : int = -1
var is_effect_expanded : bool = false
var is_expanding : bool = false
var properties : Array = []

onready var effect_type_vbox : VBoxContainer = $VBoxContainer/VBoxContainer
onready var effect_switch : CheckButton = $VBoxContainer/EffectsHeader/EffectSwitch
onready var effect_expand : TextureButton = $VBoxContainer/EffectsHeader/Expand
onready var expanded_y : float = effect_type_vbox.rect_size.y + 60

func _ready():
	var _err = effect_expand.connect("pressed", self,"expand_effect")


func _enter_tree():
	init_color()


func init_color() -> void:
	self.get_stylebox("panel").set_bg_color( SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "AudioEffectsBackground") )


func set_audio_effect(var property_idx : int, var new_value : float) -> void:
	var effect : AudioEffect = AudioServer.get_bus_effect(0, effect_idx)
	var Property : String = properties[property_idx]
	effect.set_deferred(Property, new_value)
	SongLists.audio_effects.effects[effect_idx][Property] = new_value


func call_effect_containers(var method : String) -> void:
	# looping through all effect property containers and calling a method on them
	# because, since they are not simply structured in a Vbox
	for i in effect_type_vbox.get_child_count():
		if effect_type_vbox.get_child(i) is Label:
			# skipping the Label that Describe the SubEffect
			continue;
			
		for j in effect_type_vbox.get_child(i).get_child_count():
			self.call(method, effect_type_vbox.get_child(i).get_child(j))


func init_effect_container(var effect_container : Control) -> void:
	var new_value : float = SongLists.audio_effects.effects[effect_idx][properties[effect_container.property_idx]]
	effect_container.set_value(new_value)
	var _err = effect_container.connect("audio_effect_sub_value_changed", self,"set_audio_effect")
	set_audio_effect(effect_container.property_idx, new_value)


func update_effect_container(var effect_container : Control) -> void:
	var new_value : float = SongLists.audio_effects.effects[effect_idx ][properties[effect_container.property_idx]]
	effect_container.set_value( 
		new_value
	)


func get_expand_height() -> float:
	for i in effect_type_vbox.get_children():
		if i is GridContainer:
			return i.rect_size.y
	return 350.0


func expand_effect() -> void:
	if is_expanding:
		return;
	
	is_expanding = true
	var tw : SceneTreeTween = create_tween()
	tw = tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	var _err = tw.connect("finished",self,"set",["is_expanding",false])
	var dis : float = 0.0
	var height : float = 0.0
	if !is_effect_expanded:
		effect_expand.texture_normal = MINUS_TEXTURE
		_err = tw.connect("finished",self.effect_type_vbox,"set_visible",[true])
		dis = effect_type_vbox.rect_size.y + 60 - self.rect_min_size.y
		height = expanded_y
	else:
		self.effect_type_vbox.set_visible(false)
		effect_expand.texture_normal = PLUS_TEXTURE
		dis = self.rect_min_size.y - shrinked_y
		height = shrinked_y
	
	# calculating duration, since the distance is not constant
	var duration : float = dis / tw_speed
	
	# just ignoring the calculation for now
	duration = 0.5
	
	var ptw : PropertyTweener = tw.tween_property(
		self,
		"rect_min_size:y",
		height,
		duration
	)
	
	is_effect_expanded = !is_effect_expanded
