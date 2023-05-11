extends "res://src/Scenes/General/SonglistBlocker.gd"
# a script that handles the animation of some possible options that can appear on screen

var is_tweening : bool = false

func _ready():
	self.modulate.a = 0.0
	is_tweening = true
	var tw : PropertyTweener =  get_tree().create_tween().tween_property(
		self,
		"modulate:a",
		1.0,
		0.1
	)
	yield(tw,"finished")
	is_tweening = false


func exit_player_option() -> void:
	var tw : SceneTreeTween = get_tree().create_tween()
	var _ptw = tw.tween_property(
		self,
		"modulate:a",
		0.0,
		0.1
	)
	
	is_tweening = true
	yield(tw,"finished")
	is_tweening = false
	self.queue_free()
