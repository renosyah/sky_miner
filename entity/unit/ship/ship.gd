extends BaseUnit
class_name Ship

export var acceleration :float = 0.78

var throttle :float

func _ready():
	enable_gravity = false
	
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_throttle", throttle)
		
# multiplayer func
puppet var _puppet_throttle :float

func master_moving(delta :float) -> void:
	var _is_moving :bool = move_direction != Vector3.ZERO
	var _acc :float = acceleration if _is_moving else -acceleration
	throttle = lerp(throttle, throttle + _acc, delta)
	throttle = clamp(throttle, 0, speed)
	_velocity = -transform.basis.z * throttle
	
	.turn_spatial_pivot_to_moving(self, clamp(throttle, 0, 0.5), delta)
	.master_moving(delta)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	throttle = _puppet_throttle
