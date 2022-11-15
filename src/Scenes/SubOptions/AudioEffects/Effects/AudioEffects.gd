extends PanelContainer


#NODES
onready var Effects : VBoxContainer = $ScrollContainer/EffectBackground/Effects
onready var Header : PanelContainer = $ScrollContainer/EffectBackground/Effects/EffectsMainHeader

#VARIABLES
var is_tweening : bool = false

func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


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
	Global.root.top_ui.add_child(x)
	x.connect("text_saved",self,"SavePreset")
	x.set_topic("Preset Title")


func SavePreset(var preset_name : String) -> void:
	# checking preset name
	if !is_valid_preset_name(preset_name):
		Global.root.message("Invalid Preset Name", SaveData.MESSAGE_ERROR, true)
		return
	
	#Saving the Preset with the Main enabled -> will be replaced on Load
	var NewPreset : Array = SongLists.audio_effects
	SaveData.save(
		Global.get_current_user_data_folder() + "/Settings/AudioEffects/Presets/" + preset_name + ".epr",
		NewPreset
	)
	
	#Updating Preset Selection
	Header.InitPresetSelection()


func LoadPreset(var PresetIdx : int) -> void:
	var main_enabled : bool = SongLists.audio_effects[SongLists.audio_effects.size() - 1]["main_enabled"]
	var PresetTitle : String = Header.PresetSelection.get_popup().get_item_text(PresetIdx)
	var PresetData = SaveData.load_data(Global.get_current_user_data_folder() + "/Settings/AudioEffects/Presets/" + PresetTitle)
	
	if !PresetData:
		Global.root.message("LOADING PRESET: " + PresetTitle,  SaveData.MESSAGE_ERROR)
		return;
	
	#Setting Preset as Current Audio Effect
	
	PresetData[PresetData.size() - 1]["main_enabled"] = main_enabled
	SongLists.audio_effects = PresetData
	
	#Updating the Effects
	var EffectIdx : int = -1
	
	for i in Effects.get_child_count():
		if Effects.get_child(i).get("EffectIdx") != null:
			#!= null must be -> else thinks 0 is false
			EffectIdx = Effects.get_child(i).EffectIdx
			Effects.get_child(i).CallEffectContainers("UpdateEffectContainer")
			Effects.get_child(i).EffectSwitch.OnEffectToggled(SongLists.audio_effects[EffectIdx]["enabled"])


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
