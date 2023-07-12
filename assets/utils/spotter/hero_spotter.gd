extends Area
class_name HeroSpotter

export var detection_range :int = 15
export var team :int

var unit_targets :Array = []
var resource_targets :Array = []

var ignore_body

onready var _collision_shape = $CollisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	(_collision_shape.shape as CylinderShape).radius = detection_range
	
func set_enable(_enable :bool):
	_collision_shape.set_deferred("disabled", not _enable)
	
func get_alive_unit_targets() -> Array:
	var _unit_targets :Array = []
	
	for i in unit_targets:
		var unit :BaseUnit = i
		if not unit.is_dead:
			_unit_targets.append(unit)
			
	return _unit_targets
	
func get_alive_resource_targets() -> Array:
	var _resource_targets :Array = []
	
	for i in resource_targets:
		var resource :BaseResources = i
		if not resource.is_dead:
			_resource_targets.append(resource)
			
	return _resource_targets
	
func _on_spotter_body_entered(body):
	if body == ignore_body:
		return
		
	_check_is_unit(body)
	_check_is_resource(body)
	
func _check_is_unit(body):
	if not body is BaseUnit:
		return
		
	if body.team == team:
		return
		
	unit_targets.append(body)
	
func _check_is_resource(body):
	if not body is BaseResources:
		return
		
	resource_targets.append(body)
	
func _on_spotter_body_exited(body):
	if resource_targets.has(body):
		resource_targets.erase(body)
		
	if unit_targets.has(body):
		unit_targets.erase(body)
	
	























