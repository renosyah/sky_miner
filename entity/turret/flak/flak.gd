extends Turret

const firing_sound = preload("res://assets/sounds/flak/flak.wav")

onready var animation_player = $AnimationPlayer
onready var from = $body/gun/from

func _ready():
	_sound.stream = firing_sound

func firing(_projectile :Projectile, _target :BaseUnit):
	_sound.play()
	animation_player.play("firing")
	_muzzle_position = from.global_transform.origin
	.firing(_projectile, _target)




