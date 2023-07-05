extends Spatial
class_name Turret

signal fired(_turret)
signal reload(_turret, _finish)

export var target :NodePath

export var aiming_speed :float
export var ignore_body :NodePath

export var projectile :PackedScene
export var attack_damage :int
export var ammo :int
export var max_ammo :int
export var reload_time :float
export var fire_rate :float

export var body :NodePath
export var gun :NodePath

export var enable :bool
export var is_master :bool

var _pivot :Spatial
var _reload_timer :Timer
var _firing_timer :Timer
var _iddle_timer :Timer
var _muzzle_position :Vector3
var _pool_projectile :Array

var _body :Spatial
var _gun :Spatial

var _sound :AudioStreamPlayer3D
var _is_reloading :bool = false

func _ready():
	_pivot = Spatial.new()
	add_child(_pivot)
	
	_reload_timer = Timer.new()
	_reload_timer.wait_time = reload_time
	_reload_timer.one_shot = true
	_reload_timer.connect("timeout", self, "reload_finish")
	add_child(_reload_timer)
	
	_firing_timer = Timer.new()
	_firing_timer.wait_time = fire_rate
	_firing_timer.one_shot = true
	add_child(_firing_timer)
	
	_iddle_timer = Timer.new()
	_iddle_timer.wait_time = 3
	_iddle_timer.one_shot = true
	add_child(_iddle_timer)
	
	_sound = AudioStreamPlayer3D.new()
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	
	_body = get_node_or_null(body)
	_gun = get_node_or_null(gun)
	
	_pooling_projectile()
	
func _pooling_projectile():
	for i in 10:
		var p = projectile.instance()
		p.connect("reach", self, "projectile_reach_target")
		add_child(p)
		_pool_projectile.append(p)
		
func current_fire_rate_time() -> float:
	return _firing_timer.time_left
	
func current_reload_time() -> float:
	return _reload_timer.time_left
		
func _get_projectile() -> Projectile:
	for _projectile in _pool_projectile:
		if not _projectile.is_launching():
			return _projectile
			
	return null
	
func _process(delta):
	if enable:
		var _target: BaseUnit = _get_target()
		_aiming(_target, delta)
		_idle(_target, delta)
	
func _idle(_target :BaseUnit, _delta :float):
	if is_instance_valid(_target):
		return
		
	if not _iddle_timer.is_stopped():
		return
		
	_pivot.rotation_degrees.y = rand_range(0, 360)
	_pivot.rotation_degrees.x = rand_range(-25, 25)
	_iddle_timer.start()
	
func _aiming(_target :BaseUnit, delta :float):
	if not is_instance_valid(_body):
		return
		
	if not is_instance_valid(_gun):
		return
		
	var _is_taget_valid :bool = is_instance_valid(_target)
		
	if _is_taget_valid:
		var from_pos :Vector3 = _pivot.global_transform.origin
		var to_pos :Vector3 = _target.global_transform.origin
		
		var _aim_dir :Vector3 = from_pos + from_pos.direction_to(to_pos) * 10
		_pivot.look_at(_aim_dir, Vector3.UP)
		
		_pivot.rotation_degrees.y = wrapf(_pivot.rotation_degrees.y, 0.0, 360.0)
		_pivot.rotation_degrees.x = clamp(_pivot.rotation_degrees.x, -60, 60)
		
	_body.rotation.y = lerp_angle(_body.rotation.y, _pivot.rotation.y, aiming_speed * delta)
	_gun.rotation_degrees.x = lerp(_gun.rotation_degrees.x, _pivot.rotation_degrees.x, aiming_speed * delta)
	_gun.rotation_degrees.x = clamp(_gun.rotation_degrees.x, -45, 60)
	
	if _is_taget_valid:
		_align_aim(_target)
	
func _get_target() -> BaseUnit:
	if target.is_empty():
		return null
		
	var _body_target = get_node_or_null(target)
	if not is_instance_valid(_body_target):
		return null
		
	if not _body_target is BaseUnit:
		return null
		
	return _body_target
	
func _align_aim(_target :BaseUnit):
	if not _reload_timer.is_stopped():
		return
		
	if not is_align(_target.global_transform.origin):
		return
		
	if _firing_timer.is_stopped():
		_firing_timer.wait_time = fire_rate
		_firing_timer.start()
		_firing(_target)
		
func reload_finish():
	ammo = max_ammo
	emit_signal("reload", self, true)
	
# get turret body position & add foward direction
# with appy rotation from basis and ajust elevation 
# to get aiming position then align it
# if distance between aligment & target less than 5m
# open fired
func is_align(_target_pos :Vector3) -> bool:
	var _from_pos :Vector3 = _body.global_transform.origin
	var _dist :float = _from_pos.distance_to(_target_pos)
	var _to_pos :Vector3 = _from_pos + -_body.global_transform.basis.z * _dist
	_to_pos.y = _target_pos.y
	return _to_pos.distance_to(_target_pos) < 5
	
func _firing(_target :BaseUnit):
	if not is_instance_valid(_target):
		return
		
	var _projectile :Projectile = _get_projectile()
	if not is_instance_valid(_projectile):
		return
		
	ammo -= 1
	
	firing(_projectile, _target)
	
	_projectile.translation = _muzzle_position
	_projectile.target = _target
	_projectile.launch()
	
	if ammo < 1:
		_reload_timer.wait_time = rand_range(reload_time * 0.5, reload_time)
		_reload_timer.start()
		emit_signal("reload", self, false)
		
	
func firing(_projectile :Projectile, _target :BaseUnit):
	emit_signal("fired", self)
	
func projectile_reach_target(_p :Projectile, _t :BaseUnit):
	if is_master and attack_damage > 0:
		_t.take_damage(attack_damage)
	







