extends Control

#PRELOADS
const plus_texture : StreamTexture = preload("res://src/Assets/Icons/White/General/add_1_72px.png")
const minus_texture : StreamTexture = preload("res://src/Assets/Icons/White/General/remove_1_72px.png")

#CONSTANT
const EXPANDED_Y : float = 350.0
const SHRINKED_Y : float = 42.0

#NODES
onready var EffectTypeVBox : VBoxContainer = $VBoxContainer/VBoxContainer
onready var EffectSwitch : CheckButton = $VBoxContainer/EffectsHeader/EffectSwitch
onready var EffectExpand : TextureButton = $VBoxContainer/EffectsHeader/Expand

#VARIABLES
var EffectIdx : int = -1
var IsEffectExpanded : bool = false
var IsExpanding : bool = false
var Properties : Array = []


func _enter_tree():
	InitColor()


func _ready():
	var _err = EffectExpand.connect("pressed", self,"ExpandEffect")


func InitColor() -> void:
	self.get_stylebox("panel").set_bg_color( SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS, "AudioEffectsBackground") )


func SetAudioEffect(var PropertyIdx : int, var NewValue : float) -> void:
	var Effect : AudioEffect = AudioServer.get_bus_effect(0, EffectIdx)
	var Property : String = Properties[PropertyIdx]
	Effect.set_deferred(Property, NewValue)
	SongLists.AudioEffects[EffectIdx][Property] = NewValue


func CallEffectContainers(var Method : String) -> void:
	#Looping through all effect property containers and calling a method on them
	#because, since they are not simply structured in a Vbox
	for i in EffectTypeVBox.get_child_count():
		if EffectTypeVBox.get_child(i) is Label:
			#Skipping the Label that Describe the SubEffect
			continue;
			
		for j in  EffectTypeVBox.get_child(i).get_child_count():
			self.call(Method, EffectTypeVBox.get_child(i).get_child(j))


func InitEffectContainer(var EffectContainer : Control) -> void:
	var NewValue : float = SongLists.AudioEffects[ EffectIdx ][ Properties[EffectContainer.PropertyIdx] ]
	EffectContainer.SetValue( 
		NewValue
	)
	var _err = EffectContainer.connect("AudioEffectSubValueChanged", self,"SetAudioEffect")
	SetAudioEffect(EffectContainer.PropertyIdx, NewValue)


func UpdateEffectContainer(var EffectContainer : Control) -> void:
	var NewValue : float = SongLists.AudioEffects[ EffectIdx ][ Properties[EffectContainer.PropertyIdx] ]
	EffectContainer.SetValue( 
		NewValue
	)
	

func ExpandEffect() -> void:
	if IsExpanding:
		return;
	
	IsExpanding = true
	var tw : SceneTreeTween = create_tween()
	var _err = tw.connect("finished",self,"set",["IsExpanding",false])
	
	if !IsEffectExpanded:
		EffectExpand.texture_normal = minus_texture
		_err = tw.connect("finished",self.EffectTypeVBox,"set_visible",[true])
		var ptw : PropertyTweener = tw.tween_property(
			self,
			"rect_min_size:y",
			EXPANDED_Y,
			0.3
		)
	else:
		EffectExpand.texture_normal = plus_texture
		self.EffectTypeVBox.set_visible(false)
		var ptw : PropertyTweener = tw.tween_property(
			self,
			"rect_min_size:y",
			SHRINKED_Y,
			0.3
		)
	IsEffectExpanded = !IsEffectExpanded
