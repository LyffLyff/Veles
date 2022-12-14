extends Control
# script handling the container shown when an error or message must be displayed to the user

const DURATION : float = 0.3

onready var message_panel : PanelContainer = $VBoxContainer/Message
onready var message_label : Label = $VBoxContainer/Message/Label

func _ready():
	self.rect_position.y = 150
	message_label.set_text("  " + Global.displayed_message + "  ")
	Global.request_fps_change(60)
	message_tween(0, 1.0)
	yield(get_tree().create_timer(1.5),"timeout")
	Global.request_fps_change(60)
	message_tween(150, 0.0)
	yield(get_tree().create_timer(DURATION),"timeout")
	Global.request_fps_change(4)
	self.queue_free()


func message_tween(var final_y_val : float, var final_mod_val : float) -> void:
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_CUBIC)
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


func set_background_color(var clr : Color) -> void:
	message_panel.get_stylebox("panel").set_bg_color(clr)
