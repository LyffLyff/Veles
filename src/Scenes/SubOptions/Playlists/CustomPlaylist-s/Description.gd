extends VBoxContainer

var file_path : String = ""
var is_expanded : bool = false

onready var description_edit : TextEdit = $ScrollContainer/Description
onready var animations : AnimationPlayer = $DescriptionAnimations

func load_description(var file_path : String) -> void:
	file_path = file_path
	var description_text = SaveData.load_data(file_path)
	if description_text != null:
		description_edit.set_text(description_text)


func save_description():
	# automatically creates the given description file if used
	SaveData.save(file_path, description_edit.get_text())


func _on_Expand_pressed():
	if !is_expanded:
		animations.play("Expand")
	else:
		animations.play_backwards("Expand")
	is_expanded = !is_expanded
