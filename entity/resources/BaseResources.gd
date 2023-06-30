extends StaticBody
class_name BaseResources

const coal_icon = preload("res://assets/ui/icons/resources/coal.png")
const food_icon = preload("res://assets/ui/icons/resources/food.png")
const iron_icon = preload("res://assets/ui/icons/resources/iron.png")
const wood_icon = preload("res://assets/ui/icons/resources/wood.png")

enum type_resource_enum { none,wood,food,iron,coal }

signal take_damage(_resource, _damage)
signal dead(_resource)
signal reset(_resource)


export(type_resource_enum) var type_resource = type_resource_enum.none
export var map_seed :int

export var is_dead :bool = false
export var hp :int = 10
export var max_hp :int = 10

var _collision :CollisionShape
onready var _rng :RandomNumberGenerator = RandomNumberGenerator.new()

# performace
var _visibility_notifier :VisibilityNotifier
var _tween :Tween

remotesync func _take_damage(_damage :int, _remain_hp :int):
	hp = _remain_hp
	
	if _visibility_notifier.is_on_screen():
		_tween.interpolate_property(self, "scale", Vector3.ONE * 0.7, Vector3.ONE,0.2,Tween.TRANS_BOUNCE)
		_tween.start()
		
	emit_signal("take_damage", self, _damage)
	
remotesync func _dead():
	is_dead = true
	hp = 0
	emit_signal("dead", self)
	
remotesync func _reset():
	is_dead = false
	hp = max_hp
	set_process(true)
	emit_signal("reset", self)
	
func _ready() -> void:
	_visibility_notifier = VisibilityNotifier.new()
	_visibility_notifier.max_distance = 80
	_visibility_notifier.connect("camera_entered", self, "_on_camera_entered")
	_visibility_notifier.connect("camera_exited", self , "_on_camera_exited")
	add_child(_visibility_notifier)
	
	_tween = Tween.new()
	add_child(_tween)
	
func _on_camera_entered(_camera: Camera):
	if is_dead:
		return
		
	visible = true
	
func _on_camera_exited(_camera: Camera):
	if is_dead:
		return
		
	visible = false
	
func _create_collision_shape(_mesh :MeshInstance):
	_mesh.create_convex_collision()
	_mesh.software_skinning_transform_normals = false
	
	_collision = _mesh.get_child(0).get_child(0)
	_mesh.get_child(0).remove_child(_collision)
	add_child(_collision)
	_mesh.get_child(0).queue_free()
	
	_collision.rotation_degrees.y = _mesh.rotation_degrees.y
	
func get_resource_icon() -> Resource:
	match (type_resource):
		type_resource_enum.wood:
			return wood_icon
		type_resource_enum.iron:
			return iron_icon
		type_resource_enum.coal:
			return coal_icon
		type_resource_enum.none:
			return null
	return null
	
func take_damage(_damage :int):
	if is_dead:
		return
		
	hp -= _damage
	rpc_unreliable("_take_damage", _damage, hp)
	
	if hp < 0:
		dead()
		
func dead():
	if is_dead:
		return
		
	rpc("_dead")
	
func reset(_sync :bool = true):
	if _sync:
		rpc("_reset")
		
	else:
		_reset()
	


