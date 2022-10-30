extends HBoxContainer


#SIGNAL
signal TimestampChanged

#NODES
onready var MoveUp : TextureButton = $MovingUpDown/Up
onready var MoveDown : TextureButton = $MovingUpDown/Down
onready var TimeStamp : LineEdit = $TimeInSeconds

#SIGNALS
#signal On


func OnTimestampTextChanged(var _NewText : String):
	emit_signal("TimestampChanged")
