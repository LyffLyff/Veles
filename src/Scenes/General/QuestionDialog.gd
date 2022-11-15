extends PanelContainer
# a general dialogue that asks a question and can either receive yes or no as a user input

signal conformation
signal agreed
signal disagreed

onready var question_label : Label = $PanelContainer/HBoxContainer/VBoxContainer/Question

func n_ready(var Question : String) -> void:
	question_label.set_text(Question)


func disagreed():
	emit_signal("disagreed")
	emit_signal("conformation")
	self.queue_free()


func agreed():
	emit_signal("agreed")
	emit_signal("conformation")
	self.queue_free()
