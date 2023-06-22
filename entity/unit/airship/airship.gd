extends BaseUnit
class_name AirShip

export var color_coat :Color
export var acceleration :float = 0.78
export var altitude :float = 20

export var turret_positions :Array

var turrets :Array = []
var throttle :float
var rotate_direction :float

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_throttle", throttle)
		rset_unreliable("_puppet_rotate_direction", rotate_direction)
		
# multiplayer func
puppet var _puppet_throttle :float
puppet var _puppet_rotate_direction :float

func master_moving(delta :float) -> void:
	var _is_moving :bool = move_direction != Vector3.ZERO
	var _acc :float = acceleration if _is_moving else -acceleration
	
	throttle = lerp(throttle, throttle + _acc, delta)
	throttle = clamp(throttle, 0, speed)
	
	var _move :Vector3 = -transform.basis.z * throttle
	_velocity = Vector3(_move.x, _velocity.y, _move.z)
	
	_ajust_altitude()
	
	var y_rotation :float = rotation_degrees.y
	.turn_spatial_pivot_to_moving(self, clamp(throttle, 0, 0.5), delta)
	
	rotate_direction = clamp(rotation_degrees.y - y_rotation, -1, 1)
	.master_moving(delta)
	
func _ajust_altitude():
	if translation.y < altitude:
		_velocity.y = speed
		
	if translation.y > altitude + 5:
		_velocity.y = -speed
		
	else:
		_velocity.y = 0
		
func assign_turret_target(_targets :Array):
	if _targets.empty():
		return
	
	var pos :int = 0
	for _turret in turrets:
		if _targets.empty():
			_turret.is_aiming = false
			continue
			
		_turret.is_aiming = true
		_turret.aim_at = _targets[pos].global_transform.origin
			
		if pos < _targets.size() - 1:
			pos += 1
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	throttle = _puppet_throttle
	rotate_direction = _puppet_rotate_direction
