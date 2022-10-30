extends Control


func _on_RichTextLabel_meta_clicked(meta):
	if OS.shell_open(meta) != OK:
		Global.root.Message("OPENING URL: " + str(meta),  SaveData.MESSAGE_ERROR )
