extends Turret

const launch = preload("res://assets/sounds/explosions/missile_away.wav")

onready var _missiles = [
	$body/missiles/missile_1,
	$body/missiles/missile_2,
	$body/missiles/missile_3,
	$body/missiles/missile_4
]

onready var from = $body/gun/from

func _ready():
	max_ammo = clamp(max_ammo, 0 ,4)
	ammo = max_ammo

func reload_finish():
	.reload_finish()
	for i in _missiles:
		i.visible = true
		
func firing(_projectile :Projectile, _target :BaseUnit):
	_muzzle_position = from.global_transform.origin
	.firing(_projectile, _target)
	
	_sound.stream = launch
	_sound.play()
	
	for i in _missiles:
		if i.visible:
			i.visible = false
			return
