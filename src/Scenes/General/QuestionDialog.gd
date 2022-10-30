extends PanelContainer


#SIGNALS
signal Conformation
signal Yes
signal No

#NODES
onready var QuestionLabel : Label = $PanelContainer/HBoxContainer/VBoxContainer/Question


func NReady(var Question : String) -> void:
	QuestionLabel.set_text(Question)


func No():
	emit_signal("No")
	emit_signal("Conformation")
	self.queue_free()


func Yes():
	emit_signal("Yes")
	emit_signal("Conformation")
	self.queue_free()
