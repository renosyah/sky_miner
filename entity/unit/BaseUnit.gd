extends BaseEntity
class_name BaseUnit

export var team :int = 0
export var speed :int = 1

export var move_direction :Vector3

export var is_bot :bool = false
export var is_moving :bool = false
export var enable_gravity :bool = true
export var margin :float = 0.2
var move_to :Vector3

var _velocity :Vector3 = Vector3.ZERO

var _sound :AudioStreamPlayer3D
onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")

############################################################
# multiplayer func
puppet var _puppet_rotation :Vector3
puppet var _puppet_translation :Vector3

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_rotation", global_transform.basis.get_euler())
		
############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	_sound = AudioStreamPlayer3D.new()
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	input_ray_pickable = false
	
func master_moving(delta :float) -> void:
	_bot_move()
	
	if not is_on_floor() and enable_gravity:
		_velocity.y = -_gravity
		
	if _velocity != Vector3.ZERO:
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
func _bot_move():
	if is_moving and is_bot:
		move_direction = translation.direction_to(move_to)
		if translation.distance_to(move_to) < margin:
			is_moving = false
	
func puppet_moving(delta :float) -> void:
	translation = translation.linear_interpolate(_puppet_translation, 2.5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)

func turn_spatial_pivot_to_moving(_spatial :Spatial, _interpolate :float, delta :float):
	if move_direction == Vector3.ZERO:
		return
		
	var _look_at :Vector3 = move_direction * 100
	_look_at.y = translation.y
	
	var _transform :Transform = _spatial.transform.looking_at(_look_at, Vector3.UP)
	_spatial.transform = _spatial.transform.interpolate_with(_transform, _interpolate * delta)

