extends Area
class_name Spotter

export var detection_range :int = 15
export var team :int

var targets :Array = []
var ignore_body

onready var _collision_shape = $CollisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	(_collision_shape.shape as CylinderShape).radius = detection_range
	
func _on_spotter_body_entered(body):
	if body is StaticBody:
		return
		
	if body == ignore_body:
		return
		
	if not body is BaseUnit:
		return
		
	if body.is_dead:
		return
		
	if body.team == team:
		return
		
	targets.append(body)
	
	
func _on_spotter_body_exited(body):
	if not targets.has(body):
		return
		
	targets.erase(body)
