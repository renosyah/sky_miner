extends Turret

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
	_muzzle_position = from.global_transform.origin
	_aiming_position = to.global_transform.origin
	animation_player.play("firing")
	.firing(_target)
