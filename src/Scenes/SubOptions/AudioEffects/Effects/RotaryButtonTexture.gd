extends Button

signal rotation_changed

# the smaller this value the more the Button rotates with smaller mouse position changes
const ROTATION_STEP_PIXELS : float = 0.5
const ROTATION_RANGE : Vector2 = Vector2(0,360)

var mouse_start_pos : Vector2 = Vector2.ZERO
var current_rotation_degrees : float = 0.0
var new_rotation_degrees : float = 0.0
var y_mouse_offset : float = 0.0
var real_value : float = -1.0
var max_value : float = -1.0
var min_value : float = -1.0

onready var rotating_sprite : Sprite = get_child(0)

func _ready():
	self.set_process(false)
	_on_RotaryButton_item_rect_changed()


func _process(_delta):
	y_mouse_offset = mouse_start_pos.y - get_global_mouse_position().y
	new_rotation_degrees = ( y_mouse_offset / ROTATION_STEP_PIXELS ) + current_rotation_degrees
	new_rotation_degrees = check_range(new_rotation_degrees);
	rotating_sprite.rotation_degrees = new_rotation_degrees
	# calculating the Real Value from the Rotation
	real_value = ((max_value - min_value) * new_rotation_degrees / ROTATION_RANGE.y) + min_value
	emit_signal("rotation_changed", real_value)


func _on_RotaryButton_button_down() -> void:
	mouse_start_pos = get_global_mouse_position()
	self.set_process(true)


func _on_RotaryButton_button_up() -> void:
	current_rotation_degrees = rotating_sprite.rotation_degrees
	self.set_process(false)


func _on_RotaryButton_item_rect_changed():
	# makes it so the texture will always be rotated from the center
	rotating_sprite.position = self.rect_size / 2


func check_range(var rotation_degrees : float) -> float:
	if rotation_degrees > ROTATION_RANGE.y:
		return ROTATION_RANGE.y;
	elif rotation_degrees < ROTATION_RANGE.x:
		return ROTATION_RANGE.x;
	return rotation_degrees;


func set_rotation(var new_rotation : float) -> void:
	current_rotation_degrees = new_rotation
	rotating_sprite.rotation_degrees = new_rotation


func value_to_rotation(var new_value : float) -> float:
	# converting a value to the buttons rotations
	# does this by multiplying a ratio of the currents value from the absolute distance
	# between the min./max. value and then multiplying with the maximum rotation
	var diff : float = abs(min_value) + abs(max_value)
	var linear_range_of_value : float = abs(min_value) + new_value
	return (linear_range_of_value / diff) * ROTATION_RANGE.y
