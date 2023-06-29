extends BaseEntity
class_name BaseUnit

signal take_damage(_unit, _damage)
signal dead(_unit)
signal reset(_unit)

export var team :int = 0
export var speed :int = 1

export var is_dead :bool = false
export var hp :int = 100
export var max_hp :int = 100

export var move_direction :Vector3

export var is_bot :bool = false
export var is_moving :bool = false
export var enable_gravity :bool = true
export var margin :float = 3
var move_to :Vector3

var _pivot :Spatial
var _velocity :Vector3 = Vector3.ZERO

var _sound :AudioStreamPlayer3D
onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")

# performace
var _visibility_notifier :VisibilityNotifier

############################################################
# multiplayer func
puppet var _puppet_rotation :Vector3
puppet var _puppet_translation :Vector3

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not enable_network:
		return
		
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_rotation", global_transform.basis.get_euler())
		
############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	_pivot = Spatial.new()
	add_child(_pivot)
	_pivot.set_as_toplevel(true)
	
	_sound = AudioStreamPlayer3D.new()
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	
	input_ray_pickable = false
	
	_visibility_notifier = VisibilityNotifier.new()
	_visibility_notifier.max_distance = 120
	add_child(_visibility_notifier)
	
remotesync func _take_damage(_damage :int, _remain_hp :int):
	hp = _remain_hp
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
	
func master_moving(_delta :float) -> void:
	if not enable_network:
		return
		
	_bot_move()
	
	if not is_on_floor() and enable_gravity:
		_velocity.y = -_gravity
		
	if _velocity != Vector3.ZERO:
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
		
func _bot_move():
	if is_dead:
		return
		
	if is_moving and is_bot:
		var _pos :Vector3 = global_transform.origin
		var _pos_norm :Vector3 = _pos * Vector3(1,0,1)
		var _move_to_norm :Vector3 = move_to * Vector3(1,0,1)
		var _dist :float = _pos_norm.distance_to(_move_to_norm)
		var _input_power :float = clamp(_dist * 0.10, 0, 1)
		move_direction = _pos_norm.direction_to(_move_to_norm) * _input_power
		if _dist < margin:
			move_direction = Vector3.ZERO
			is_moving = false
	
func puppet_moving(delta :float) -> void:
	if not enable_network or not _puppet_ready:
		return
		
	translation = translation.linear_interpolate(_puppet_translation, 2.5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)

func turn_spatial_pivot_to_moving(_spatial :Spatial, _interpolate :float, delta :float):
	if move_direction == Vector3.ZERO:
		return
	
	var _pos :Vector3 = global_transform.origin
	var _look_at :Vector3 = _pos + move_direction * 100
	_look_at.y = translation.y
	
	_pivot.translation = _pos
	
	_pivot.look_at(_look_at, Vector3.UP)
	_pivot.rotation_degrees.y = wrapf(_pivot.rotation_degrees.y, 0.0, 360.0)
	_pivot.rotation_degrees.x = clamp(_pivot.rotation_degrees.x, -45, 45)
	
	_spatial.rotation.y = lerp_angle(_spatial.rotation.y, _pivot.rotation.y, _interpolate * delta)
	
func get_velocity() -> Vector3:
	return _velocity
	
func take_damage(_damage :int):
	if not enable_network:
		return
		
	if is_dead:
		return
		
	hp -= _damage
	rpc_unreliable("_take_damage", _damage, hp)
	
	if hp < 0:
		dead()
		
func dead():
	if not enable_network:
		return
		
	if is_dead:
		return
		
	rpc("_dead")
	
func reset(_sync :bool = true):
	if not enable_network:
		return
		
	if _sync:
		rpc("_reset")
		
	else:
		_reset()
	





