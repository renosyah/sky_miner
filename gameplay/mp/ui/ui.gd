extends Control
class_name UiMp

onready var virtual_joystick = $CanvasLayer/Control/SafeArea/VBoxContainer/Control/virtual_joystick
onready var hurt_indicator = $CanvasLayer/Control/hurt

func get_joystick_direction() -> Vector3:
	return virtual_joystick.get_v3_output()
	
func hide_hurt():
	hurt_indicator.hide_hurt()
	
func show_hurt():
	hurt_indicator.show_hurt()
	
func show_hurting():
	hurt_indicator.show_hurting()
