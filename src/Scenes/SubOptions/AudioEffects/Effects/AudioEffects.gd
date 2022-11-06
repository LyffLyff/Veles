extends PanelContainer


#NODES
onready var Effects : VBoxContainer = $ScrollContainer/EffectBackground/Effects
onready var Header : PanelContainer = $ScrollContainer/EffectBackground/Effects/EffectsMainHeader

#VARIABLES
var is_tweening : bool = false

func _enter_tree():
	Global.root.ToggleSongScrollerInput(false)


func _exit_tree():
	Global.root.ToggleSongScrollerInput(true)


func _ready():
	#Connect Signals
	var _err = Header.Close.connect("pressed",self,"FreeAudioEffects")
	_err = Header.AddPreset.connect("pressed",self,"SaveCurrentAsPreset")
	_err = Header.PresetSelection.get_popup().connect("index_pressed",self, "LoadPreset")
	
	#Start Tween
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_CUBIC)
	var ptw : PropertyTweener = tw.tween_property(
		Effects,
		"rect_min_size:y",
		297.0,
		0.3
	)
	ptw = tw.parallel().tween_property(
		self,
		"self_modulate:a",
		1.0,
		0.3
	)
	is_tweening = true
	yield(tw,"finished")
	is_tweening = false
	for Effect in Effects.get_children():
		Effect.show()


func SaveCurrentAsPreset() -> void:
	var x = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	Global.root.TopUI.add_child(x)
	x.connect("TextSave",self,"SavePreset")
	x.SetTopic("Preset Title")


func SavePreset(var preset_name : String) -> void:
	# checking preset name
	if !is_valid_preset_name(preset_name):
		Global.root.Message("Invalid Preset Name", SaveData.MESSAGE_ERROR, true)
		return
	
	#Saving the Preset with the Main enabled -> will be replaced on Load
	var NewPreset : Array = SongLists.AudioEffects
	SaveData.Save(
		Global.GetCurrentUserDataFolder() + "/Settings/AudioEffects/Presets/" + preset_name + ".epr",
		NewPreset
	)
	
	#Updating Preset Selection
	Header.InitPresetSelection()


func LoadPreset(var PresetIdx : int) -> void:
	var MainEnabled : bool = SongLists.AudioEffects[SongLists.AudioEffects.size() - 1]["main_enabled"]
	var PresetTitle : String = Header.PresetSelection.get_popup().get_item_text(PresetIdx)
	var PresetData = SaveData.Load(Global.GetCurrentUserDataFolder() + "/Settings/AudioEffects/Presets/" + PresetTitle)
	
	if !PresetData:
		Global.root.Message("LOADING PRESET: " + PresetTitle,  SaveData.MESSAGE_ERROR)
		return;
	
	#Setting Preset as Current Audio Effect
	
	PresetData[PresetData.size() - 1]["main_enabled"] = MainEnabled
	SongLists.AudioEffects = PresetData
	
	#Updating the Effects
	var EffectIdx : int = -1
	
	for i in Effects.get_child_count():
		if Effects.get_child(i).get("EffectIdx") != null:
			#!= null must be -> else thinks 0 is false
			EffectIdx = Effects.get_child(i).EffectIdx
			Effects.get_child(i).CallEffectContainers("UpdateEffectContainer")
			Effects.get_child(i).EffectSwitch.OnEffectToggled(SongLists.AudioEffects[EffectIdx]["enabled"])


func FreeAudioEffects() -> void:
	#End Tween
	if is_tweening:
		return;
	
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_QUAD)
	for Effect in Effects.get_children():
		Effect.hide()
	var ptw : PropertyTweener = tw.tween_property(
		Effects,
		"rect_min_size:y",
		0.0,
		0.3
	)
	ptw = tw.parallel().tween_property(
		self,
		"self_modulate:a",
		0.0,
		0.3
	)
	is_tweening = true
	yield(tw,"finished")
	is_tweening = false
	self.queue_free()


func is_valid_preset_name(var preset_name : String) -> bool:
	if !preset_name.is_valid_filename() or preset_name in Header.presets:
		return false
	return true
