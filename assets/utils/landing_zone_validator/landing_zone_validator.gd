extends Spatial
class_name LandingZoneValidator

export var follow_body :NodePath
export var enable :bool setget _set_enable

var is_valid :bool = false
var position :Vector3

onready var _follow_body :AirShip = get_node_or_null(follow_body)
onready var _ray_cast = $RayCast
onready var _marker = $marker

func _ready():
	_marker.set_as_toplevel(true)
	_ray_cast.set_deferred("enabled", enable)
	_ray_cast.add_exception(_follow_body)

func _set_enable(_val :bool):
	enable = _val
	
	if is_instance_valid(_ray_cast):
		_ray_cast.set_deferred("enabled", enable)
	
func _process(_delta):
	is_valid = false
	_marker.visible = is_valid
	
	if not enable:
		return
		
	if _follow_body.throttle > 0.5:
		return
		
	if _ray_cast.is_colliding():
		if _ray_cast.get_collider() is FloatingIsland:
			is_valid = true
			_marker.visible = is_valid
			var pos = _ray_cast.get_collision_point()
			_marker.translation = pos
			position = pos
