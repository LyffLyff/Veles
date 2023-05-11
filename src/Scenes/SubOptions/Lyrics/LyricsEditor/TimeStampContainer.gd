extends HBoxContainer

signal timestemp_edited

onready var timestamp_edit : LineEdit = $TimeInSeconds

func _on_TimeInSeconds_text_changed(var _new_text : String):
	emit_signal("timestemp_edited")


func _on_TimeInSeconds_text_entered(var new_text : String):
	timestamp_edit.release_focus()


func _on_TimeInSeconds_focus_exited():
	timestamp_edit.text = timestamp_edit.text.pad_decimals(2)
