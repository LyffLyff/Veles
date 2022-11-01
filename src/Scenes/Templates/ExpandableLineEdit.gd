extends HBoxContainer


#NODES
onready var LineEditVbox : VBoxContainer = $VBoxContainer
onready var TitleLabel : Label = $Title/Title


#PRELOADS
const SingleExpandableLineEdit : PackedScene = preload("res://src/scenes/Templates/SingleExpandableLineEdit.tscn")

#EXPORTS
export var Title : String = "Title"


func _ready():
	TitleLabel.set_text( Title + ":" )
	AddSelection()


func AddSelection() -> void:
	var x : HBoxContainer = SingleExpandableLineEdit.instance()
	if LineEditVbox.get_child_count() > 0:
		x.get_node("PlusMinus").set_normal_texture( load("res://src/Assets/Icons/White/General/remove_1_72px.png") )
	LineEditVbox.add_child( x )
	if x.get_node("PlusMinus").connect("pressed", self, "OnPlusMinusPressed", [ x ] ):
		Global.root.Message("CANNOT CONNECT pressed Signal to OnPlusMinusPressed function", SaveData.MESSAGE_ERROR)


func OnPlusMinusPressed(var Ref : Node) -> void:
	if Ref.get_index() == 0:
		AddSelection()
	else:
		LineEditVbox.remove_child( Ref )
		Ref.queue_free()
