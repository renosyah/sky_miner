extends Spatial
class_name Bot

export var enable :bool = true
export var unit :NodePath
export var team :int
export var chase_offset :float

var _target :BaseUnit
var _unit :BaseUnit

onready var _spotter = $spotter

# Called when the node enters the scene tree for the first time.
func _ready():
	_unit = get_node_or_null(unit)
	_spotter.ignore_body = _unit
	_spotter.team = team
	_unit.is_bot = enable
	
func _process(_delta):
	if enable:
		_assign_target()
		_chase_target()
		
func move_to(_at :Vector3):
	if not is_instance_valid(_unit):
		return
		
	if _unit.is_moving:
		return
		
	if enable:
		_unit.is_moving = true
		_unit.move_to = _at
	
func get_node_path_targets() -> Array:
	var _targets :Array = []
	
	for i in _spotter.targets:
		var _unit :BaseUnit = i
		if not is_instance_valid(_unit):
			continue
			
		if _unit.is_dead:
			continue
			
		_targets.append(i.get_path())
			
	return _targets
	
func _chase_target():
	if not is_instance_valid(_target):
		return
		
	_unit.is_moving = true
	_unit.move_to = _get_rand_pos(_target.global_transform.origin, chase_offset)
	
func _get_rand_pos(from :Vector3, offset :float) -> Vector3:
	if offset < 1:
		return from
		
	var angle := rand_range(0, TAU)
	var posv2 = polar2cartesian(offset, angle)
	var posv3 = from + Vector3(posv2.x, 2.0, posv2.y)
	return posv3
	
func _assign_target():
	_target = _get_closes()
	
func _get_closes() -> BaseUnit:
	if _spotter.targets.empty():
		return null
		
	var from :Vector3 = global_transform.origin
	var default :BaseUnit = _spotter.targets[0]
	for i in _spotter.targets:
		var dis_1 = from.distance_squared_to(default.global_transform.origin)
		var dis_2 = from.distance_squared_to(i.global_transform.origin)
		
		if dis_2 < dis_1:
			default = i
		
	return default
