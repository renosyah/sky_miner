extends BaseUnit
class_name AirShip

export var color_coat :Color
export var acceleration :float = 0.78
export var altitude :float = 20

export var turret_positions :Array

var turrets :Array = []

var throttle :float
var rotate_direction :float
var targets :Array

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_throttle", throttle)
		rset_unreliable("_puppet_targets", targets)
		
# multiplayer func
puppet var _puppet_throttle :float
puppet var _puppet_rotate_direction :float
puppet var _puppet_targets :Array

func assign_turret_target(_targets :Array):
	if _is_master:
		targets = _targets
		
func master_moving(delta :float) -> void:
	if is_dead:
		_falling_down(delta)
		.master_moving(delta)
		return
		
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
	
func moving(delta :float) -> void:
	.moving(delta)
	_turret_get_target()
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	throttle = _puppet_throttle
	rotate_direction = _puppet_rotate_direction
	targets = _puppet_targets
	
func _ajust_altitude():
	if translation.y < altitude:
		_velocity.y = throttle
		
	elif translation.y > altitude + 0.2:
		_velocity.y = -throttle
		
	else:
		_velocity.y = 0
		
func _falling_down(delta):
	var is_grounded :bool = is_on_floor()
	var is_below_surface :bool = translation.y < -5
	
	if is_grounded or is_below_surface:
		set_process(false)
		return
		
	# still flying?
	# down & rotate
	throttle = lerp(throttle, throttle + 1.5, delta)
	throttle = clamp(throttle, 0, speed)
	
	_velocity = Vector3(0, -throttle, 0)
	rotate_y(1.2 * delta)
	
	
func _turret_get_target():
	var pos :int = 0
	for _turret in turrets:
		if  targets.empty() or is_dead:
			_turret.target = NodePath("")
			
		else:
			_turret.target = targets[pos]
			
			if pos < targets.size() - 1:
				pos += 1
	
