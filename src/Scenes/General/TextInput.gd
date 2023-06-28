extends LineEdit


func _ready():
	self.connect("text_entered", self, "release_focus")
