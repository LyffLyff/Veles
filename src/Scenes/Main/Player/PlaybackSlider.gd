extends HSlider

const TIMESTAMP_OFFSET : int = 15

var timestamp_label : Label = null

func _ready():
	init_playback_slider()
	self.set_process(false)


func _process(var _delta):
	timestamp_label.rect_global_position.x = clamp(get_global_mouse_position().x - 2 - (timestamp_label.rect_size.x / 2.0), self.rect_global_position.x, self.rect_global_position.x + self.rect_size.x)
	timestamp_label.text = TimeFormatter.format_seconds(get_current_hover_value())


func init_playback_slider() -> void:
	self.step = 0.001
	self.set_process(false)


func get_current_hover_value() -> float:
	# returns the approximated value where the mouse if currently hovering
	return get_current_mouse_ratio() * self.max_value


func get_current_mouse_ratio() -> float:
	# returns a value between 0 and 1 representing the position on the playback slider
	return clamp((self.get_global_mouse_position().x - self.rect_global_position.x) / self.rect_size.x, 0.0, 1.0)


func _on_PlaybackSlider_mouse_entered():
	timestamp_label = Label.new()
	timestamp_label.set("custom_fonts/font", load("res://src/Ressources/Fonts/NotoSans_Bold_10px.tres"))
	timestamp_label.rect_min_size.x = 30
	Global.root.top_ui.add_child(timestamp_label)
	timestamp_label.rect_global_position.y = self.rect_global_position.y - TIMESTAMP_OFFSET
	self.set_process(true)


func _on_PlaybackSlider_mouse_exited():
	self.set_process(false)
	timestamp_label.queue_free()
