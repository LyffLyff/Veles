extends Panel


#Window Resizer
#Listens to the Windows Size and Emits Signals when specific Sizes have been 


signal window_smaller
signal window_bigger


var last_window_size : Vector2 = self.rect_size


func _on_Window_resized():
	#The Background Panel Always has the size of the whole window 
	if last_window_size.x > rect_size.x or last_window_size.y > rect_size.y:
		emit_signal("window_smaller",self.rect_size)
	else:
		emit_signal("window_bigger",self.rect_size)
