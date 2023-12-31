extends BaseUnit
class_name GroundUnit

export var attack_damage :int
export var attack_delay :float
export var attack_range :float
export var color_coat :Color

var target # BaseUnit or BaseResources
var final_attack_damage :int
var final_attack_range :float

var _attack_delay_timer :Timer
var _hit_particle :HitParticle

var _animation_states :Dictionary = {}

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not enable_network:
		return
		
	if not _is_master or not _is_online:
		return
		
	var _target_path :NodePath
	
	if is_instance_valid(target):
		_target_path = target.get_path()
		
	rset_unreliable("_puppet_target", _target_path)
	rset_unreliable("_puppet_animation_states", _animation_states)
		
# multiplayer func
puppet var _puppet_target :NodePath
puppet var _puppet_animation_states :Dictionary

remotesync func _take_damage(_damage :int, _remain_hp :int):
	._take_damage(_damage, _remain_hp)
	_hit_particle.display_hit(
		"-%s" % _damage, Color.orangered, global_transform.origin
	)
	
func _ready():
	enable_gravity = true
	is_bot = true
	is_moving = false
	margin = 0.3
	
	_attack_delay_timer = Timer.new()
	_attack_delay_timer.wait_time = attack_delay
	_attack_delay_timer.one_shot = true
	add_child(_attack_delay_timer)
	
	_hit_particle = preload("res://assets/visual_effect/hit_particle/hit_particle.tscn").instance()
	_hit_particle.custom_particle_scene =  preload("res://assets/visual_effect/hit_particle/custom_particle/text/custom_text_particle.tscn")
	add_child(_hit_particle)
	_hit_particle.set_as_toplevel(true)
	
func master_moving(delta :float) -> void:
	if is_dead:
		return
		
	if translation.y < -2:
		dead()
		set_process(false)
		return
		
	var _input_power :float = move_direction.length()
	var _is_moving :bool = _input_power > 0.1
	
	var _move :Vector3 = -global_transform.basis.z * _input_power * speed
	_velocity = Vector3(_move.x, _velocity.y, _move.z)
	
	var _y_rotation :float = rotation_degrees.y
	turn_spatial_pivot_to_moving(self, 5, delta)
	
	var _rotate_direction :float = clamp(rotation_degrees.y - _y_rotation, -1, 1)
	var _roll_rotation_speed :float = _input_power if _is_moving else 1.0
	
	rotation_degrees.z = lerp(rotation_degrees.z, _rotate_direction * 15, _roll_rotation_speed * delta)
	rotation_degrees.x = 0
	
	.master_moving(delta)
	
func moving(delta :float) -> void:
	.moving(delta)

	if is_dead:
		return
	
	if not is_instance_valid(target):
		return
		
	var pos :Vector3 = global_transform.origin
	var target_pos :Vector3 = target.global_transform.origin
	
	if pos.distance_to(target_pos) > final_attack_range:
		return
		
	if not _is_align(target_pos):
		return
		
	if _attack_delay_timer.is_stopped():
		perform_attack()
		_attack_delay_timer.start()
		
		
func _is_align(_target_pos :Vector3) -> bool:
	var _from_pos :Vector3 = global_transform.origin
	var _dist :float = _from_pos.distance_to(_target_pos)
	var _to_pos :Vector3 = _from_pos + -global_transform.basis.z * _dist
	_to_pos.y = _target_pos.y
	return _to_pos.distance_to(_target_pos) < 2
	
func perform_attack():
	if target is BaseUnit:
		if _is_master:
			target.take_damage(final_attack_damage)
		
	elif target is BaseResources:
		if _is_master:
			target.take_damage(final_attack_damage)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	if not enable_network or not _puppet_ready:
		return
		
	target = get_node_or_null(_puppet_target)
	_animation_states = _puppet_animation_states


