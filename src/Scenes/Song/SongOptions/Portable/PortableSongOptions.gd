extends "res://src/Scenes/Song/SongOptions/SongOptions.gd"
# portable Song Options
# these Song Options will be revealed as soon as a song is right clicked

const PORTABLE_SONG_OPTIONS_OFFSET : int = 40

func _ready():
	# checking x position
	if get_global_mouse_position().x + self.rect_size.x > OS.window_size.x:
		# options too far right
		self.rect_global_position.x = get_global_mouse_position().x - self.rect_size.x + 5
	elif get_global_mouse_position().x - PORTABLE_SONG_OPTIONS_OFFSET <= 0:
		# options too far left
		self.rect_global_position.x = 20
	else:
		self.rect_global_position.x = get_global_mouse_position().x - PORTABLE_SONG_OPTIONS_OFFSET
	
	# checking y position
	if get_global_mouse_position().y + self.rect_size.y > OS.window_size.y:
		# options too far below
		self.rect_global_position.y = get_global_mouse_position().y - self.rect_size.y + 40
	elif get_global_mouse_position().y - PORTABLE_SONG_OPTIONS_OFFSET <= 0:
		# options above window
		self.rect_global_position.y = 10
	else:
		# options normal height
		self.rect_global_position.y = get_global_mouse_position().y - PORTABLE_SONG_OPTIONS_OFFSET
