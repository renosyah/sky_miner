extends Area
class_name HeroSpotter

export var detection_range :int = 3
export var team :int

var targets :Array = []
var ignore_body

onready var _collision_shape = $CollisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	(_collision_shape.shape as CylinderShape).radius = detection_range
	
func set_enable(_enable :bool):
	_collision_shape.set_deferred("disabled", not _enable)
	
func _on_spotter_body_entered(body):
	if body == ignore_body:
		return
		
	_check_is_unit(body)
	_check_is_resource(body)
	
func _check_is_unit(body):
	if not body is BaseUnit:
		return
		
	if body.is_dead:
		return
		
	if body.team == team:
		return
		
	targets.append(body)
	
func _check_is_resource(body):
	if not body is BaseResources:
		return
		
	if body.is_dead:
		return
		
	targets.append(body)
	
func _on_spotter_body_exited(body):
	if not targets.has(body):
		return
		
	targets.erase(body)
