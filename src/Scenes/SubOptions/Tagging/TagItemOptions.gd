extends "res://src/Scenes/General/MovablePopupMenu.gd"

signal extended_tags_pressed

var filepath : String = ""
var item_idx

func init_item_options(var path : String) -> void:
	filepath = path


func _on_RevealInExplorer_pressed():
	OS.shell_open(filepath.get_base_dir())
	self.unload_popup()


func _on_PlayExternally_pressed():
	OS.shell_open(filepath)
	self.unload_popup()


func _on_ExtendedTags_pressed():
	emit_signal("extended_tags_pressed", filepath)
	self.unload_popup()
