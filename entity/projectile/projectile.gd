extends Spatial
class_name Projectile

signal reach(projectile, target)

export var speed :int = 12
export var magin :float = 0.5
export var max_distance :float = 25

var target :BaseUnit

var _launching :bool
var _target :Vector3
var _direction :Vector3
var _travel_distance :float

func _ready():
	_launching = false
	set_as_toplevel(true)
	set_process(false)

func launch():
	_target = target.global_transform.origin
	_direction = _get_pos().direction_to(_target)
	_travel_distance = 0
	_launching = true
	set_process(true)
	
func is_launching() -> bool:
	return _launching
	
func _get_pos() -> Vector3:
	return global_transform.origin
	
func _process(delta):
	_target = target.global_transform.origin
	
	if _get_pos().distance_to(_target) < magin:
		_reach()
		return
		
	if _travel_distance > max_distance:
		stop()
		return
		
	_travel_distance += speed * delta
	translation += _direction * speed * delta
	
func _reach():
	stop()
	emit_signal("reach", self, target)
	
func stop():
	_launching = false
	set_process(false)
	













