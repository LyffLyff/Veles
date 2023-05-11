extends "res://src/Scenes/General/SonglistBlocker.gd"
# standard Background Panel for Popups

signal popup_exited

const blur : ShaderMaterial = preload("res://src/Ressources/Shaders/SimpleBlur.tres")

var counter : int = 0

func _ready():
	blur.set_local_to_scene(true)
	self.material = blur
	self.modulate.a = 0.0
	var _ptw : PropertyTweener = tween_background(1.0)


func tween_background(var alpha : float, var custom_tweener : Control = self) -> PropertyTweener:
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_LINEAR)
	var ptw : PropertyTweener = tw.parallel().tween_property(
		custom_tweener,
		"modulate:a",
		alpha,
		0.25
	)
	return ptw


func exit_popup(var custom_node : Control = self) -> void:
	self.set_process(false)
	self.emit_signal("popup_exited")
	yield(tween_background(0.0, custom_node), "finished")
	self.queue_free()
