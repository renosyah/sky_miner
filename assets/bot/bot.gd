extends Spatial
class_name Bot

signal enemy_detected
signal enemy_lose

export var unit :NodePath
export var team :int
export var chase_offset :float
export var autochase :bool = true

var _target :BaseUnit
var _unit :BaseUnit
var _unit_default_margin :float

onready var _spotter = $spotter

# Called when the node enters the scene tree for the first time.
func _ready():
	_unit = get_node_or_null(unit)
	_spotter.ignore_body = _unit
	_spotter.team = team
	_spotter.connect("enemy_detected", self, "_enemy_detected")
	_spotter.connect("enemy_lose", self, "_enemy_lose")
	
	_unit_default_margin = _unit.margin
	
func _enemy_detected():
	emit_signal("enemy_detected")
	
func _enemy_lose():
	emit_signal("enemy_lose")
	
func get_unit() -> BaseUnit:
	return _unit
	
func _process(_delta):
	if autochase:
		_assign_target()
		_chase_target()
		
func move_to(_at :Vector3, margin :int = 0, force :bool = false):
	if not is_instance_valid(_unit):
		return
		
	if _unit.is_moving and not force:
		return
		
	_unit.margin = _unit_default_margin if margin == 0 else float(margin)
	_unit.is_moving = true
	_unit.move_to = _at
	
func get_node_path_targets() -> Array:
	var _targets :Array = []
	
	for i in _spotter.targets:
		var _unit_spotted :BaseUnit = i
		if not is_instance_valid(_unit_spotted):
			continue
			
		if _unit_spotted.is_dead:
			continue
			
		_targets.append(_unit_spotted.get_path())
			
	return _targets
	
func _chase_target():
	if not is_instance_valid(_target):
		return
		
	if _target.is_dead:
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
		
	if default.is_dead:
		return null
		
	return default
