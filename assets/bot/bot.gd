extends Spatial
class_name Bot

export var unit :NodePath
export var team :int

var targets :Array = []

var _target :BaseUnit
var _unit :BaseUnit

# Called when the node enters the scene tree for the first time.
func _ready():
	_unit = get_node_or_null(unit)
	_unit.is_bot = true
	
func _process(delta):
	_assign_target()
	_chase_target()
	
func _chase_target():
	_unit.is_moving = false
	
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










		
