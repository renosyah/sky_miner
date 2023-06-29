extends StaticBody
class_name BaseResources

enum type_resource_enum { none,wood,food,stone }

signal harvest(_resource, _amount_taken)
signal depleted(_resource)

var rng :RandomNumberGenerator
export(type_resource_enum) var type_resource = type_resource_enum.none

export var is_depleted :bool = false
export var amount :int = 10
export var max_amount :int = 10

var collision :CollisionShape

# performace
var _visibility_notifier :VisibilityNotifier
var _tween :Tween

remotesync func _harvest(_amount_taken :int, _remain :int):
	amount = _remain
	if _visibility_notifier.is_on_screen():
		_tween.interpolate_property(self, "scale", Vector3.ONE * 0.7, Vector3.ONE,0.2,Tween.TRANS_BOUNCE)
		_tween.start()
	
	emit_signal("harvest", self, _amount_taken)
	
remotesync func _depleted():
	is_depleted = true
	amount = 0
	emit_signal("depleted", self)
	
func _ready() -> void:
	_visibility_notifier = VisibilityNotifier.new()
	_visibility_notifier.max_distance = 80
	_visibility_notifier.connect("camera_entered", self, "_on_camera_entered")
	_visibility_notifier.connect("camera_exited", self , "_on_camera_exited")
	add_child(_visibility_notifier)
	
	_tween = Tween.new()
	add_child(_tween)
	
func _on_camera_entered(_camera: Camera):
	if is_depleted:
		return
		
	visible = true
	
func _on_camera_exited(_camera: Camera):
	if is_depleted:
		return
		
	visible = false
	
func _create_collision_shape(_mesh :MeshInstance):
	_mesh.create_convex_collision()
	_mesh.software_skinning_transform_normals = false

	collision = _mesh.get_child(0).get_child(0)
	_mesh.get_child(0).remove_child(collision)
	add_child(collision)
	_mesh.get_child(0).queue_free()
	
	collision.rotation_degrees.y = _mesh.rotation_degrees.y
	
func harvest(_amount_taken :int):
	if is_depleted:
		return
		
	amount -= _amount_taken
	rpc_unreliable("_harvest", _amount_taken, amount)
	
	if amount < 0:
		depleted()
		
func depleted():
	if is_depleted:
		return
		
	rpc("_depleted")
	
