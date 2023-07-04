extends Turret

const firing_sound = preload("res://assets/sounds/mg_firings/firing_2.wav")

onready var animation_player = $AnimationPlayer
onready var from = $body/gun/from

func _pooling_projectile():
	#._pooling_projectile()
	for i in 25:
		var p = projectile.instance()
		p.speed = 18
		p.connect("reach", self, "projectile_reach_target")
		add_child(p)
		_pool_projectile.append(p)
		
func firing(_projectile :Projectile, _target :BaseUnit):
	_sound.stream = firing_sound
	_sound.play()
	animation_player.play("firing")
	_muzzle_position = from.global_transform.origin
	.firing(_projectile, _target)
