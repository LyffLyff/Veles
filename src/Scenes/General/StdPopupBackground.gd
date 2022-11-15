extends PanelContainer
# standard Background Panel for Popups


func _ready():
	self.modulate.a = 0.0
	var _tw : SceneTreeTween = tween_background(1.0)


func tween_background(var alpha : float) -> SceneTreeTween:
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_LINEAR)
	var _ptw = tw.tween_property(
		self,
		"modulate:a",
		alpha,
		0.25
	)
	return tw


func exit_popup() -> void:
	self.set_process(false)
	yield(tween_background(0.0), "finished")
	self.queue_free()
