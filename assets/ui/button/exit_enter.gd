extends Button

signal press
signal exit
signal enter

export var enable :bool
export var wait_time :float = 15

onready var exit_icon = $airship_potrait/exit_icon
onready var enter_icon = $airship_potrait/enter_icon
onready var texture_progress = $airship_potrait/TextureProgress
onready var button_cooldown = $airship_potrait/button_cooldown

onready var currently_exit :bool = false

func _ready():
	check_exit_status()

func start():
	button_cooldown.wait_time = wait_time
	button_cooldown.start()
	set_process(true)
	
func _process(_delta):
	texture_progress.value = button_cooldown.time_left
	texture_progress.max_value = button_cooldown.wait_time

func _on_exit_enter_pressed():
	if not button_cooldown.is_stopped() or not enable:
		return
		
	emit_signal("press")
	
func press():
	if not button_cooldown.is_stopped() or not enable:
		return
		
	currently_exit = not currently_exit
	check_exit_status()
	
	if currently_exit:
		emit_signal("exit")
		
	else:
		emit_signal("enter")
		
	start()
	
func check_exit_status():
	exit_icon.visible = not currently_exit
	enter_icon.visible = currently_exit
	
func _on_button_cooldown_timeout():
	set_process(false)
