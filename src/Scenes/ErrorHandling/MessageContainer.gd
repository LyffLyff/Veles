extends Control
# script handling the container shown when an error or message must be displayed to the user

const DURATION : float = 0.23

onready var message_panel : PanelContainer = $VBoxContainer/Message
onready var message_label : Label = $VBoxContainer/Message/Label

func _ready():
	self.rect_position.y = 120
	message_label.set_text("  " + Global.displayed_message + "  ")
	Global.request_fps_change(60)
	message_tween(0, 1.0)
	yield(get_tree().create_timer(1.5),"timeout")
	Global.request_fps_change(60)
	message_tween(120, 0.0)
	yield(get_tree().create_timer(DURATION),"timeout")
	Global.request_fps_change(4)
	self.queue_free()


func init_message(var message_type : int) -> void:
	var bg_clr : Color = Color()
	match message_type:
		Enumerations.MESSAGE_ERROR:
			bg_clr = Color("AE1700")
		Enumerations.MESSAGE_NOTICE:
			bg_clr = Color("808080")
		Enumerations.MESSAGE_SUCCESS:
			bg_clr = Color("307227")
		Enumerations.MESSAGE_WARNING:
			bg_clr = Color("d5a830")
		_:
			bg_clr = Color("AE1700")
	
	message_panel.get_stylebox("panel").set_bg_color(bg_clr)


func message_tween(var final_y_val : float, var final_mod_val : float) -> void:
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	var _ptw : PropertyTweener = tw.tween_property(
		self,
		"rect_position:y",
		final_y_val,
		DURATION
	)
	_ptw = tw.parallel().tween_property(
		message_panel,
		"modulate:a",
		final_mod_val,
		DURATION
	)
