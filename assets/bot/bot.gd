extends Spatial
class_name Bot

export var enable :bool = true
export var unit :NodePath
export var team :int
export var detection_range :int = 15

var targets :Array = []

var _target :BaseUnit
var _unit :BaseUnit

onready var _collision_shape = $Area/CollisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	_unit = get_node_or_null(unit)
	_unit.is_bot = true
	(_collision_shape.shape as SphereShape).radius = detection_range
	
func _process(delta):
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
	
func _chase_target():
	if not is_instance_valid(_target):
		return
		
	_unit.is_moving = true
	_unit.move_to = _target.global_transform.origin
	
func _assign_target():
	_target = _get_closes()
	
func _get_closes() -> BaseUnit:
	if targets.empty():
		return null
		
	var from :Vector3 = global_transform.origin
	var default :BaseUnit = targets[0]
	for i in targets:
		var dis_1 = from.distance_squared_to(default.global_transform.origin)
		var dis_2 = from.distance_squared_to(i.global_transform.origin)
		
		if dis_2 < dis_1:
			default = i
		
	return default
	
func _on_Area_body_entered(body):
	if body is StaticBody:
		return
		
	if body == _unit:
		return
		
	if not body is BaseUnit:
		return
		
	if body.team == team:
		return
		
	targets.append(body)

func _on_Area_body_exited(body):
	if not targets.has(body):
		return
		
	targets.erase(body)










		
