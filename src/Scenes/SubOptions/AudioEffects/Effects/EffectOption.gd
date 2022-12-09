extends VBoxContainer


#NODES
onready var EffectLabel : Label = $Name
onready var ESlider : VSlider = $Changer

#VARIABLES
export var EffectName : String = ""

 
func _ready():
	EffectLabel.text = EffectName
	#Automatically sets the Effect Value to the Actual Valuze of the Slider on Ready
	ESlider.emit_signal("value_changed",ESlider.value)


func GetValue() -> float:
	return ESlider.get_value()
