extends Area
class_name ExitArea

onready var units :Array

onready var _mesh_instance = $MeshInstance

func _ready():
	_mesh_instance.set_surface_material(0, preload("res://map/exit_area/glowing_area.tres").duplicate())
	
func set_enable(_val :bool):
	set_deferred("monitoring", _val)

func _on_exit_area_body_entered(body):
	if units.has(body):
		return
	
	if not body is BaseUnit:
		return
		
	units.append(body)

func _on_exit_area_body_exited(body):
	if not units.has(body):
		return
		
	units.erase(body)
