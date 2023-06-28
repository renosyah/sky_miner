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
onready var button_cooldown = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/exit_enter/airship_potrait/button_cooldown
onready var texture_progress = $CanvasLayer/Control/SafeArea/HBoxContainer/VBoxContainer/Control/exit_enter/airship_potrait/TextureProgress

onready var _allow_exit :bool = false
onready var _currently_exit :bool = false

func _ready():
	_check_exit_status()
	
func make_ready():
	button_cooldown.wait_time = 15
	button_cooldown.start()

func _process(_delta):
	texture_progress.value = button_cooldown.time_left
	texture_progress.max_value = button_cooldown.wait_time

func get_joystick_direction() -> Vector3:
	return virtual_joystick.get_v3_output()
	
func hide_hurt():
	hurt_indicator.hide_hurt()
	
func show_hurt():
	hurt_indicator.show_hurt()
	
func show_hurting():
	hurt_indicator.show_hurting()
	
func show_exit_button(_show :bool):
	_allow_exit = _show
	
	if not _allow_exit:
		exit_enter.modulate.a = 0.5
		return
		
	exit_enter.modulate.a = 1
	
func _check_exit_status():
	exit_icon.visible = not _currently_exit
	enter_icon.visible = _currently_exit
	
func _on_exit_enter_pressed():
	if not button_cooldown.is_stopped():
		return
		
	if not _allow_exit:
		return
		
	_currently_exit = not _currently_exit
	
	button_cooldown.start()
	_check_exit_status()
	
	if _currently_exit:
		emit_signal("exit_airship")
	else:
		emit_signal("enter_airship")












