extends VBoxContainer

onready var dimensions_label : Label = $Dimensions
onready var datasize_label : Label = $Datasize
onready var mime_type_label : Label = $MimeType
onready var cover_type_label : Label = $CoverType


func init_image_properties(var dimensions : Vector2, var datasize_in_bytes : int, var mime_type : String, var cover_type : String) -> void:
	dimensions_label.text = str(dimensions.x) + "x" + str(dimensions.y)
	datasize_label.text = String.humanize_size(datasize_in_bytes)
	mime_type_label.text = mime_type
	cover_type_label.text = cover_type


func multiple_selected() -> void:
	datasize_label.text = ""
	mime_type_label.text = ""
	cover_type_label.text = ""
	dimensions_label.text = "Multiple Files"
