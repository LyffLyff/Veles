extends VBoxContainer


#SIGNAL
signal AudioEffectSubValueChanged


#NODES
onready var RotaryButton : Button = $RotaryButton
onready var RotaryEdit : LineEdit = $RotaryEdit
onready var TitleLabel : Label = $Title


#EXPORTS
export var Title : String = ""
export var MinValue : float = 0.0
export var MaxValue : float = 360.0


#VARIABLES
export var PropertyIdx : int = 0


func SetValue(var NewValue : float) -> void:
	#Converting the Value to the actual Rotation of the Button
	#-> RealRotation = ( (MaxRotation - MinRotation) / MaxValue * NewValue ) + MinRotation
	if NewValue < MinValue or NewValue > MaxValue:
		#Safety measure
		#even when manually entering the effects must be within Min/Max range
		NewValue = MinValue
	
	var NewRotation : float = RotaryButton.ValueToRotation(NewValue)	
	RotaryButton.SetRotation( NewRotation )
	RotaryEdit.SetRotaryEdit( NewValue )
	RotationValueChanged(NewValue, "AudioEffectSubValueChanged")


func _ready():
	RotaryButton.MinValue = MinValue
	RotaryButton.MaxValue = MaxValue
	TitleLabel.set_text( Title )
	var _err = RotaryButton.connect("RotationChanged", RotaryEdit, "SetRotaryEdit")
	_err = RotaryButton.connect("RotationChanged",self,"RotationValueChanged",["AudioEffectSubValueChanged"])


func RotationValueChanged(var NewValue : float, var _SignalText : String) -> void:
	self.emit_signal("AudioEffectSubValueChanged",PropertyIdx,NewValue)


func OnRotaryEditTextEntered(var NewValue : String) -> void:
	if NewValue.is_valid_float():
		SetValue( float(NewValue) )
		#RotaryButton.SetRotation( RotaryButton.ValueToRotation( float(NewValue) ) )
		#RotaryButton.emit_signal("RotationChanged",float(NewValue))
	else:
		RotaryEdit.SetRotaryEdit( RotaryButton.RealValue )


