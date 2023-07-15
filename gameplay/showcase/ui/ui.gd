extends Control
class_name UiShowCase

onready var hero_info = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/HBoxContainer2/hero_info
onready var virtual_joystick = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/virtual_joystick

func get_joystick_direction() -> Vector3:
	return virtual_joystick.get_v3_output()
