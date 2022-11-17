extends Button

signal right_clicked

onready var username : Label = $VBoxContainer/Username
onready var profile_img : TextureRect = $VBoxContainer/ProfileImage

func _on_UserProfileContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_RIGHT:
				emit_signal("right_clicked")
