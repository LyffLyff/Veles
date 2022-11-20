extends VBoxContainer

var is_ready : bool = false

func _ready():
	is_ready = true
	self.modulate.a = 0.0;
	var _tw : PropertyTweener = get_tree().create_tween().tween_property(self,"modulate:a",1.0,0.3)


func _process(var _delta : float):
	if !is_ready:
		return
	if !self.get_global_rect().has_point( get_global_mouse_position() ):
		unload_playlist_options()


func unload_playlist_options() -> void:
	var _tw : PropertyTweener = get_tree().create_tween().tween_property(self,"modulate:a",0.0,0.3)
	yield(
		_tw,
		"finished"
	)
	self.queue_free() 
