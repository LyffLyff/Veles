extends Button

#SIGNALS
signal RightClicked

#NODES
onready var Username : Label = $VBoxContainer/Username
onready var ProfileImg : TextureRect = $VBoxContainer/ProfileImage


func OnUserProfileContainerGUIInput(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_RIGHT:
				emit_signal("RightClicked")
