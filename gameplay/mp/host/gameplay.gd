extends BaseGameplayMp

onready var cruiser = $cruiser
onready var cruiser_2 = $cruiser2

func _process(delta):
	cruiser.move_direction = _ui.get_joystick_direction()
	_camera.translation = cruiser.translation
	_camera.set_distance(cruiser.throttle * cruiser.speed)
