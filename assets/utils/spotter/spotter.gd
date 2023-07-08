extends Area
class_name Spotter

signal enemy_detected
signal enemy_lose

export var detection_range :int = 15
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
	if body is StaticBody:
		return
		
	if body == ignore_body:
		return
		
	if not body is BaseUnit:
		return
		
	if body.team == team:
		return
		
	targets.append(body)
	emit_signal("enemy_detected")
	
	
func _on_spotter_body_exited(body):
	if not targets.has(body):
		return
		
	targets.erase(body)
	emit_signal("enemy_lose")

