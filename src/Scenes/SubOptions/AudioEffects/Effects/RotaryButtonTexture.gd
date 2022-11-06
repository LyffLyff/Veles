extends Button


#SIGNAL
signal RotationChanged


#CONSTANTS
#the smaller this value the more the Button rotates with smaller mouse position changes
const RotationStepInPixels : float = 0.5


#NODES
onready var RotatingSprite : Sprite = get_child(0)


#VARIABLES
const RotationRange : Vector2 = Vector2(0,360)
var MouseStartPos : Vector2 = Vector2.ZERO
var CurrentButtonRotationDegrees : float = 0.0
var NewRotationDegrees : float = 0.0
var YMouseOffset : float = 0.0
var RealValue : float = -1.0
var MaxValue : float = -1.0
var MinValue : float = -1.0


func _ready():
	self.set_process(false)
	OnRotaryButtonItemRectChanged()


func _process(_delta):
	YMouseOffset = MouseStartPos.y - get_global_mouse_position().y
	NewRotationDegrees = ( YMouseOffset / RotationStepInPixels ) + CurrentButtonRotationDegrees
	NewRotationDegrees = CheckRange(NewRotationDegrees);
	RotatingSprite.rotation_degrees = NewRotationDegrees
	#Calculating the Real Value from the Rotation
	RealValue = ( ( MaxValue - MinValue ) * NewRotationDegrees / RotationRange.y ) + MinValue
	
	emit_signal( "RotationChanged", RealValue)


func OnRotaryButtonButtonDown() -> void:
	MouseStartPos = get_global_mouse_position()
	self.set_process(true)


func OnRotaryButtonButtonUp() -> void:
	CurrentButtonRotationDegrees = RotatingSprite.rotation_degrees
	self.set_process(false)


func OnRotaryButtonItemRectChanged():
	#So the texture will always be rotated from the center
	RotatingSprite.position = self.rect_size / 2


func CheckRange(var RotationDegrees : float) -> float:
	if RotationDegrees > RotationRange.y:
		return RotationRange.y;
	elif RotationDegrees < RotationRange.x:
		return RotationRange.x;
	return RotationDegrees;


func SetRotation(var NewRotation : float) -> void:
	CurrentButtonRotationDegrees = NewRotation
	RotatingSprite.rotation_degrees = NewRotation


func ValueToRotation(var NewValue : float) -> float:
	# converting a value to the buttons rotations
	# does this by multiplying a ratio of the currents value from the absolute distance
	# between the min./max. value and then multiplying with the maximum rotation
	var diff : float = abs(MinValue) + abs(MaxValue)
	var linear_range_of_value : float = abs(MinValue) + NewValue
	return (linear_range_of_value / diff) * RotationRange.y
