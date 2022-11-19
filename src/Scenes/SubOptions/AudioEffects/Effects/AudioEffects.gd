extends PanelContainer

var is_tweening : bool = false

onready var effects : VBoxContainer = $ScrollContainer/EffectBackground/Effects
onready var header : PanelContainer = $ScrollContainer/EffectBackground/Effects/EffectsMainHeader

func _ready():
	# connect Signals
	var _err = header.close.connect("pressed",self,"free_audio_effects")
	_err = header.add_preset.connect("pressed",self,"save_current_as_preset")
	_err = header.preset_menu.get_popup().connect("index_pressed",self, "load_preset")
	
	# start Tween
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_CUBIC)
	var ptw : PropertyTweener = tw.tween_property(
		effects,
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
	for effect in effects.get_children():
		effect.show()


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


func save_current_as_preset() -> void:
	var x = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	Global.root.top_ui.add_child(x)
	x.connect("text_saved",self,"save_preset")
	x.set_topic("Preset Title")


func save_preset(var preset_name : String) -> void:
	# checking preset name
	if !is_valid_preset_name(preset_name):
		Global.root.message("Invalid Preset Name", SaveData.MESSAGE_ERROR, true)
		return
	
	# saving the Preset with the Main enabled -> will be replaced on Load
	var new_preset : Array = SongLists.audio_effects
	SaveData.save(
		Global.get_current_user_data_folder() + "/Settings/AudioEffects/Presets/" + preset_name + ".epr",
		new_preset
	)
	
	# updating Preset Selection
	header.init_preset_selection()


func load_preset(var preset_idx : int) -> void:
	var main_enabled : bool = SongLists.audio_effects[SongLists.audio_effects.size() - 1]["main_enabled"]
	var preset_title : String = header.preset_menu.get_popup().get_item_text(preset_idx)
	var preset_data = SaveData.load_data(Global.get_current_user_data_folder() + "/Settings/AudioEffects/Presets/" + preset_title)
	
	if !preset_data:
		Global.root.message("LOADING PRESET: " + preset_title,  SaveData.MESSAGE_ERROR)
		return;
	
	# setting Preset as Current Audio Effect
	
	preset_data[preset_data.size() - 1]["main_enabled"] = main_enabled
	SongLists.audio_effects = preset_data
	
	# updating the effects
	var effect_idx : int = -1
	
	for i in effects.get_child_count():
		if effects.get_child(i).get("effect_idx") != null:
			# != null must be -> else thinks 0 is false
			effect_idx = effects.get_child(i).effect_idx
			effects.get_child(i).call_effect_containers("update_effect_container")
			effects.get_child(i).effect_switch.on_effect_toggled(SongLists.audio_effects[effect_idx]["enabled"])


func free_audio_effects() -> void:
	# end Tween
	if is_tweening:
		return;
	
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_QUAD)
	for effect in effects.get_children():
		effect.hide()
	var ptw : PropertyTweener = tw.tween_property(
		effects,
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
	if !preset_name.is_valid_filename() or preset_name in header.presets:
		return false
	return true
