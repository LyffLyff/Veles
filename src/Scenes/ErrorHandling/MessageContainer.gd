extends Control

#CONSTANTS
const DURATION : float = 0.3

#NODES
onready var MessagePanel : PanelContainer = $VBoxContainer/Message
onready var MessageLabel : Label = $VBoxContainer/Message/Label

func _ready():
	self.rect_position.y = 150
	MessageLabel.set_text("  " + Global.DisplayedMessage + "  ")
	Global.RequestFPSChange(60)
	MessageTween(0, 1.0)
	yield(get_tree().create_timer(1.5),"timeout")
	Global.RequestFPSChange(60)
	MessageTween(150, 0.0)
	yield(get_tree().create_timer(DURATION),"timeout")
	Global.RequestFPSChange(4)
	self.queue_free()


func MessageTween(var final_y_val : float, var final_mod_val : float) -> void:
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_CUBIC)
	var _ptw : PropertyTweener = tw.tween_property(
		self,
		"rect_position:y",
		final_y_val,
		DURATION
	)
	_ptw = tw.parallel().tween_property(
		MessagePanel,
		"modulate:a",
		final_mod_val,
		DURATION
	)

func SetBackgroundColor(var clr : Color) -> void:
	MessagePanel.get_stylebox("panel").set_bg_color(clr)
