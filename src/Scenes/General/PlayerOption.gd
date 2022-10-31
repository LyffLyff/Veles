extends Control


func _ready():
	self.modulate.a = 0.0
	var _tw : PropertyTweener =  get_tree().create_tween().tween_property(
		self,
		"modulate:a",
		1.0,
		0.1
	)


func ExitPlayerOption() -> void:
	var tw : SceneTreeTween = get_tree().create_tween()
	var _ptw = tw.tween_property(
		self,
		"modulate:a",
		0.0,
		0.1
	)
	yield(tw,"finished")
	self.queue_free()
