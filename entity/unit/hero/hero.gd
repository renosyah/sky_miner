extends BaseUnit
class_name Hero

export var attack_damage :int
export var attack_delay :float
export var attack_range :float
export var color_coat :Color

var target :BaseUnit

var _attack_delay_timer :Timer
var _hit_particle :HitParticle

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not enable_network:
		return
		
	if not _is_master or not _is_online:
		return
		
	if not is_instance_valid(target):
		return
		
	rset_unreliable("_puppet_target", target.get_path())
		
# multiplayer func
puppet var _puppet_target :NodePath

remotesync func _take_damage(_damage :int, _remain_hp :int):
	._take_damage(_damage, _remain_hp)
	_hit_particle.display_hit(
		"-%s" % _damage, Color.orangered, global_transform.origin
	)
	
remotesync func _dead():
	._dead()
	
remotesync func _reset():
	._reset()
	
func _ready():
	enable_gravity = true
	
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
		.master_moving(delta)
		return
		
	var _input_power :float = move_direction.length()
	var _is_moving :bool = _input_power > 0.1
	
	var _move :Vector3 = -global_transform.basis.z * _input_power * speed
	_velocity = Vector3(_move.x, _velocity.y, _move.z)
	
	var _y_rotation :float = rotation_degrees.y
	var _rotation_power :float = clamp(_input_power * speed, 0, 0.5)
	.turn_spatial_pivot_to_moving(self, _rotation_power, delta)
	
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
	
	if pos.distance_to(target_pos) > attack_range:
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
	if _is_master:
		target.take_damage(attack_damage)
		
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	target = get_node_or_null(_puppet_target)
	
