extends Panel


var selected : Color


func SetColor(var Col : Color) -> void:
	self.set("custom_styles/bg_color",Col)
