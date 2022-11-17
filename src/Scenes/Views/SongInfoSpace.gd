extends VBoxContainer

onready var title_label : Label = $Title
onready var info_label : Label = $Info

func init_info_space(var title: String, var info : String) -> void:
	self.title_label.set_deferred("text", title + ":")
	self.info_label.set_deferred("text", info)
	self.info_label.set_deferred("text", info)
