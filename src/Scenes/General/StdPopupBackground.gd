extends PanelContainer

#Standard Background Panel for Popups


func _ready():
	self.set("custom_styles/panel", load("res://src/Ressources/Themes/PopupBackground.tres") )
	var _tw : SceneTreeTween = TweenBackground(0.73)


func TweenBackground(var alpha : float) -> SceneTreeTween:
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_LINEAR)
	var _ptw = tw.tween_property(
		self.get_stylebox("panel"),
		"bg_color:a",
		alpha,
		0.25
	)
	return tw


func ExitPopup() -> void:
	yield(TweenBackground(0.0),"finished")
	self.queue_free()
