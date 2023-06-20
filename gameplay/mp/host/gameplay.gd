extends BaseGameplayMp

func _process(delta):
	_camera.translation += _ui.get_joystick_direction() * 0.25
