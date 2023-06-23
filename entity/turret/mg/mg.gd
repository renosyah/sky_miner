extends Turret

onready var animation_player = $AnimationPlayer
onready var from = $body/gun/from
onready var to = $body/gun/to

func firing(_target :BaseUnit):
	_muzzle_position = from.global_transform.origin
	_aiming_position = to.global_transform.origin
	animation_player.play("firing")
	.firing(_target)
