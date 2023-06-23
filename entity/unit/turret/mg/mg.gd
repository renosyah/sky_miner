extends Turret

onready var animation_player = $AnimationPlayer
onready var position_3d = $body/gun/Position3D

func firing(_target :BaseUnit):
	_muzzle_position = position_3d.global_transform.origin
	animation_player.play("firing")
	.firing(_target)
	
func projectile_reach_target(_p :Projectile, _t :BaseUnit):
	.projectile_reach_target(_p, _t)
