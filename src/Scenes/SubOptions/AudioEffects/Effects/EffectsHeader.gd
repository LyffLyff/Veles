extends HBoxContainer

#NODES
onready var Title : Label = $Label
onready var EffectSwitch : CheckButton = $EffectSwitch

#EXPORTS
export var EffectTitle : String = ""
export var EffectIdx : int = -1


func _ready():
	EffectSwitch.EffectIdx = EffectIdx
	EffectSwitch.InitEffectSwitch()
	Title.set_text(EffectTitle)
