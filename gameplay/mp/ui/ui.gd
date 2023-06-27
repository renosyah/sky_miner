extends Control
class_name UiMp

signal exit_airship()
signal enter_airship()

onready var airship_info = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/HBoxContainer/airship_info
onready var virtual_joystick =  $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/virtual_joystick
onready var hurt_indicator = $CanvasLayer/Control/hurt

onready var _is_exit :bool = false

func get_joystick_direction() -> Vector3:
	return virtual_joystick.get_v3_output()
	
func hide_hurt():
	hurt_indicator.hide_hurt()
	
func show_hurt():
	hurt_indicator.show_hurt()
	
func show_hurting():
	hurt_indicator.show_hurting()
	
func _on_auto_pressed():
	_is_exit = not _is_exit
	
	if _is_exit:
		emit_signal("exit_airship")
	else:
		emit_signal("enter_airship")









