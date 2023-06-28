extends Spatial
class_name LandingZoneValidator

export var follow_body :NodePath
export var enable :bool setget _set_enable

var is_valid :bool = false
var position :Vector3

onready var _follow_body :AirShip = get_node_or_null(follow_body)
onready var _main_raycast = $RayCast
onready var _ray_casts = [$RayCast2, $RayCast3, $RayCast4, $RayCast5]
onready var _marker = $marker

func _ready():
	_marker.set_as_toplevel(true)
	_set_enable(enable)
	
func _set_enable(_val :bool):
	enable = _val
	
	set_process(enable)
	if _ray_casts and _main_raycast and _follow_body:
		for _raycast in _ray_casts + [_main_raycast]:
			_raycast.set_deferred("enabled", enable)
			_raycast.add_exception(_follow_body)
			
	if _marker:
		_marker.visible = enable
	
func _process(_delta):
	var datas = _is_all_raycast_colliding()
	is_valid = datas[0] and _follow_body.throttle < 0.5
	position = datas[1]
	
	_marker.translation = position + Vector3(0, 1, 0)
	_marker.visible = is_valid
	
	translation = _follow_body.global_transform.origin
	
func _is_all_raycast_colliding() -> Array:
	var colliding = false
	var point = Vector3.ZERO
	var body
	
	if _main_raycast.is_colliding():
		colliding = true
		body = _main_raycast.get_collider()
		if not body is FloatingIsland:
			return [false, point]
			
		point = _main_raycast.get_collision_point()
	
	if not colliding:
		return [false, point]
	
	for _ray_cast in _ray_casts:
		if _ray_cast.is_colliding():
			if body != _ray_cast.get_collider():
				return [false, point]
				
	return [true, point]







