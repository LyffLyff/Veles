extends HSlider

const TIMESTAMP_OFFSET : int = 15

var timestamp_label : Label = null

func _ready():
	init_playback_slider()
	self.set_process(false)


func _process(var _delta):
	timestamp_label.rect_global_position.x = clamp(get_global_mouse_position().x - (timestamp_label.rect_min_size.x / 2), self.rect_global_position.x, self.rect_global_position.x + self.rect_size.x)
	timestamp_label.text = TimeFormatter.format_seconds(get_current_mouse_ratio() * self.max_value)


func init_playback_slider() -> void:
	self.step = 0.1
	self.set_process(false)


func get_current_mouse_ratio() -> float:
	# returns a value between 0 and 1 representing the position on the playback slider
	return clamp((get_global_mouse_position().x - self.rect_global_position.x) / self.rect_size.x, 0.0, 1.0)


func _on_PlaybackSlider_mouse_entered():
	timestamp_label = Label.new()
	timestamp_label.rect_min_size.x = 30
	Global.root.top_ui.add_child(timestamp_label)
	timestamp_label.rect_global_position.y = self.rect_global_position.y - TIMESTAMP_OFFSET
	self.set_process(true)


func _on_PlaybackSlider_mouse_exited():
	self.set_process(false)
	timestamp_label.queue_free()
