extends Turret

const firing_sounds = [
	preload("res://assets/sounds/explosions/explosion_1.wav"),
	preload("res://assets/sounds/explosions/explosion_2.wav"),
	preload("res://assets/sounds/explosions/explosion_3.wav")
]

onready var animation_player = $AnimationPlayer
onready var from = $body/gun/from

func _ready():
	max_ammo = clamp(max_ammo, 0 ,1)
	ammo = max_ammo
	
func firing(_target :BaseUnit):
	_sound.stream = firing_sounds[rand_range(0, firing_sounds.size())]
	_sound.play()
	animation_player.play("firing")
	_muzzle_position = from.global_transform.origin
	.firing(_target)







