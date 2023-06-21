extends BaseGameplayMp

onready var cruiser = $cruiser

func _process(delta):
	cruiser.move_direction = _ui.get_joystick_direction()
	_camera.translation = cruiser.translation
	_camera.set_distance(cruiser.throttle * cruiser.speed)
