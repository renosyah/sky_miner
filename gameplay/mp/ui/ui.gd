extends Control
class_name UiMp

signal exit_airship()
signal enter_airship()

onready var airship_info = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/HBoxContainer/airship_info
onready var virtual_joystick =  $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/virtual_joystick
onready var hurt_indicator = $CanvasLayer/Control/hurt

onready var exit_enter = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/exit_enter
onready var exit_icon = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/exit_enter/airship_potrait/exit_icon
onready var enter_icon = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/exit_enter/airship_potrait/enter_icon

onready var _is_exit :bool = false

func _ready():
	exit_icon.visible = not _is_exit
	enter_icon.visible = _is_exit

func get_joystick_direction() -> Vector3:
	return virtual_joystick.get_v3_output()
	
func hide_hurt():
	hurt_indicator.hide_hurt()
	
func show_hurt():
	hurt_indicator.show_hurt()
	
func show_hurting():
	hurt_indicator.show_hurting()
	
func _on_exit_enter_pressed():
	_is_exit = not _is_exit
	
	exit_icon.visible = not _is_exit
	enter_icon.visible = _is_exit
	
	if _is_exit:
		emit_signal("exit_airship")
	else:
		emit_signal("enter_airship")












