extends Control
class_name UiMp

signal exit_airship
signal enter_airship

onready var airship_info = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/HBoxContainer/airship_info
onready var hero_info = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/HBoxContainer2/hero_info

onready var virtual_joystick =  $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/virtual_joystick
onready var hurt_indicator = $CanvasLayer/Control/hurt

onready var exit_enter = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/exit_enter
onready var action_delay = $CanvasLayer/Control/action_delay

func make_ready():
	exit_enter.start()

func get_joystick_direction() -> Vector3:
	return virtual_joystick.get_v3_output()
	
func show_exit_button(_show :bool):
	exit_enter.enable = _show
	exit_enter.modulate.a = 1.0 if exit_enter.enable else 0.5
	
func _on_exit_enter_press():
	if action_delay.is_progress():
		return
		
	action_delay.start("Boarding" if exit_enter.currently_exit else "Exiting", 5)
	yield(action_delay,"finish")
	
	exit_enter.wait_time = 15
	exit_enter.press()
	
func _on_exit_enter_enter():
	emit_signal("enter_airship")
	
func _on_exit_enter_exit():
	emit_signal("exit_airship")



