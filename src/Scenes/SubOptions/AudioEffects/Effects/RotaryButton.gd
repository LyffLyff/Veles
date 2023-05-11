extends VBoxContainer

signal audio_effect_sub_value_changed

export var title : String = ""
export var min_value : float = 0.0
export var max_value : float = 360.0
export var property_idx : int = 0

onready var rotary_button : Button = $RotaryButton
onready var rotation_edit : LineEdit = $RotaryEdit
onready var title_label : Label = $Title

func _ready():
	rotary_button.min_value = min_value
	rotary_button.max_value = max_value
	title_label.set_text( title )
	var _err = rotary_button.connect("rotation_changed", rotation_edit, "set_rotary_edit")
	_err = rotary_button.connect("rotation_changed",self,"rotation_value_changed",["audio_effect_sub_value_changed"])


func set_value(var new_value : float) -> void:
	# converting the Value to the actual Rotation of the Button
	# -> RealRotation = ( (MaxRotation - MinRotation) / max_value * new_value ) + MinRotation
	if new_value < min_value or new_value > max_value:
		# safety measure
		# even when manually entering the effects must be within Min/Max range
		new_value = min_value
	
	var new_rotation : float = rotary_button.value_to_rotation(new_value)
	rotary_button.set_rotation(new_rotation)
	rotation_edit.set_rotary_edit(new_value)
	rotation_value_changed(new_value, "audio_effect_sub_value_changed")


func rotation_value_changed(var new_value : float, var _signal_text : String) -> void:
	self.emit_signal("audio_effect_sub_value_changed",property_idx,new_value)


func _on_RotaryEdit_text_entered(var new_value : String) -> void:
	if new_value.is_valid_float():
		set_value(float(new_value))
		#rotary_button.set_rotation( rotary_button.value_to_rotation( float(new_value) ) )
		#rotary_button.emit_signal("rotation_changed",float(new_value))
	else:
		rotation_edit.set_rotary_edit( rotary_button.real_value )
	rotation_edit.release_focus()


