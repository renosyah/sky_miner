extends Turret

const firing_sounds = [
	preload("res://assets/sounds/mg_firings/firing_1.wav"),
	preload("res://assets/sounds/mg_firings/firing_2.wav"),
	preload("res://assets/sounds/mg_firings/firing_3.wav")
]

onready var animation_player = $AnimationPlayer
onready var from = $body/gun/from

func firing(_projectile :Projectile, _target :BaseUnit):
	_sound.stream = firing_sounds[rand_range(0, firing_sounds.size())]
	_sound.play()
	animation_player.play("firing")
	_muzzle_position = from.global_transform.origin
	.firing(_projectile, _target)







