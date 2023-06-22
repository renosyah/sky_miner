extends Spatial
class_name Turret

export var is_aiming :bool
export var aim_at :Vector3
export var aiming_speed :float
export var ignore_bodies :Array

export var body :NodePath
export var gun :NodePath
export var ray :NodePath

var _pivot :Spatial
var _body :Spatial
var _gun :Spatial
var _ray :RayCast
var _firing :bool

func _ready():
	_pivot = Spatial.new()
	add_child(_pivot)
	
	_body = get_node_or_null(body)
	_gun = get_node_or_null(gun)
	_ray = get_node_or_null(ray)
	
	if not is_instance_valid(_ray):
		return
		
	_ray.enabled = true
	_ray.exclude_parent = true
	
	for i in ignore_bodies:
		_ray.add_exception(i)
		
	
func _process(delta):
	_aiming(delta)
	_detect_aim()
	
func _aiming(delta):
	if not is_aiming:
		return
		
	if not is_instance_valid(_body):
		return
		
	if not is_instance_valid(_gun):
		return
		
	var _aim_dir :Vector3 = _pivot.global_transform.origin.direction_to(aim_at)
	_pivot.look_at(_aim_dir * 100, Vector3.UP)
	_pivot.rotation_degrees.x = clamp(_pivot.rotation_degrees.x, -45, 45)
	
	_body.rotation.y = lerp_angle(_body.rotation.y, _pivot.rotation.y, aiming_speed * delta)
	_gun.rotation_degrees.x = lerp(_gun.rotation_degrees.x, _pivot.rotation_degrees.x, aiming_speed * delta)
	_gun.rotation_degrees.x = clamp(_gun.rotation_degrees.x, -45, 45)
	
func _detect_aim():
	if not is_aiming:
		return
		
	_firing = false
	
	if not is_instance_valid(_ray):
		return
		
	if _ray.is_colliding():
		var body = _ray.get_collider()
		if body is StaticBody:
			return
			
		if not body is BaseUnit:
			return
		
		_firing = true
	










