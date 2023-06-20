extends Control
class_name UiMp

onready var virtual_joystick = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer2/virtual_joystick

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func get_joystick_direction() -> Vector3:
	var _dir :Vector2 = virtual_joystick.get_output()
	return Vector3(_dir.x, 0, _dir.y).normalized()
