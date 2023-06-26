extends Turret

const firing_sounds = [
	preload("res://assets/sounds/mg_firings/firing_1.wav"),
	preload("res://assets/sounds/mg_firings/firing_2.wav"),
	preload("res://assets/sounds/mg_firings/firing_3.wav")
]

onready var animation_player = $AnimationPlayer
onready var from = $body/gun/from
onready var to = $body/gun/to

func is_align(_target_pos :Vector3) -> bool:
	#.is_align(_target)
	var _from_pos :Vector3 = from.global_transform.origin
	var _to_pos :Vector3 = to.global_transform.origin
	var _dir :Vector3 = _from_pos.direction_to(_to_pos)
	var _dist :float = _from_pos.distance_to(_target_pos)
	
	var _align :Vector3 = _from_pos + _dir * _dist

	return _align.distance_to(_target_pos) < 5

func firing(_target :BaseUnit):
	_sound.stream = firing_sounds[rand_range(0, firing_sounds.size())]
	_sound.play()
	animation_player.play("firing")
	_muzzle_position = from.global_transform.origin
	.firing(_target)







