extends "res://src/Scenes/General/SonglistBlocker.gd"

signal popup_exited

var is_ready : bool = false

func _ready():
	# set popup position automatically so it is below the mouse's position
	self.rect_global_position = self.get_global_mouse_position() - Vector2(self.rect_size.x / 5, self.rect_size.y / 5)
	
	is_ready = true
	self.modulate.a = 0.0;
	var _tw : PropertyTweener = get_tree().create_tween().tween_property(self,"modulate:a",1.0,0.3)


func _process(var _delta : float):
	if !is_ready:
		return
	if !self.get_global_rect().has_point(get_global_mouse_position()):
		self.emit_signal("popup_exited")
		unload_popup()


func unload_popup() -> void:
	var tw : PropertyTweener = get_tree().create_tween().tween_property(self, "modulate:a", 0.0,0.3)
	yield(tw, "finished")
	self.queue_free() 
