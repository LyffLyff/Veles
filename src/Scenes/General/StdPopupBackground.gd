extends PanelContainer

#Standard Background Panel for Popups


func _ready():
	self.modulate.a = 0.0
	var _tw : SceneTreeTween = TweenBackground(1.0)


func TweenBackground(var alpha : float) -> SceneTreeTween:
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_LINEAR)
	var _ptw = tw.tween_property(
		self,
		"modulate:a",
		alpha,
		0.25
	)
	return tw


func ExitPopup() -> void:
	self.set_process(false)
	yield(TweenBackground(0.0),"finished")
	self.queue_free()
