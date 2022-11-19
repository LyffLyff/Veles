extends HBoxContainer

export var effect_title : String = ""
export var effect_idx : int = -1

onready var title : Label = $Label
onready var effect_switch : CheckButton = $EffectSwitch

func _ready():
	effect_switch.effect_idx = effect_idx
	effect_switch.init_effect_switch()
	title.set_text(effect_title)
