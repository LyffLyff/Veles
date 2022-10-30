extends Sprite


#VARIABLE
var Diameter : int = 70


func _ready():
	#This Sprite is used since when trying to do this with a Control Type Node,
	#it won't accept any initialising rotation values, making them show the wron rotation
	#even though it's set correctly
	self.scale /= self.texture.get_size() / Diameter
