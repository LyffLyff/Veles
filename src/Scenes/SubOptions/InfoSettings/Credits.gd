extends Control

func _on_RichTextLabel_meta_clicked(meta):
	if OS.shell_open(meta) != OK:
		Global.message("OPENING URL: " + str(meta),  Enumerations.MESSAGE_ERROR )
