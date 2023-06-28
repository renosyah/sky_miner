extends BaseUnit
class_name AirShip

const explosions = [
	preload("res://assets/sounds/explosions/explosion_1.wav"),
	preload("res://assets/sounds/explosions/explosion_2.wav"),
	preload("res://assets/sounds/explosions/explosion_3.wav")
]

export var color_coat :Color
export var acceleration :float = 0.78
export var altitude :float = 20

export var turret_positions :Array

var turrets :Array = []

var throttle :float
var rotate_direction :float
var targets :Array

var _falling_down_rotation :float = -1.2
var _last_velocity :Vector3
var _explosion_sfx :CPUParticles
var _fire_sfx :Spatial
var _hit_particle :HitParticle

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not enable_network:
		return
		
	if _is_master and _is_online:
		rset_unreliable("_puppet_throttle", throttle)
		rset_unreliable("_puppet_rotate_direction", rotate_direction)
		rset_unreliable("_puppet_targets", targets)
		
# multiplayer func
puppet var _puppet_throttle :float
puppet var _puppet_rotate_direction :float
puppet var _puppet_targets :Array

func _ready():
	enable_gravity = false
	
	_explosion_sfx = preload("res://addons/explosion/quick_explosion.tscn").instance()
	add_child(_explosion_sfx)
	_explosion_sfx.visible = false
	_explosion_sfx.set_as_toplevel(true)
	
	_fire_sfx = preload("res://assets/visual_effect/fire/fire.tscn").instance()
	add_child(_fire_sfx)
	
	_hit_particle = preload("res://assets/visual_effect/hit_particle/hit_particle.tscn").instance()
	_hit_particle.custom_particle_scene =  preload("res://assets/visual_effect/hit_particle/custom_particle/text/custom_text_particle.tscn")
	add_child(_hit_particle)
	_hit_particle.set_as_toplevel(true)
	
func assign_turret_position(_turret :Turret, _pos :Vector3):
	_turret.enable = (not is_dead)
	add_child(_turret)
	_turret.is_master = _check_is_master()
	_turret.translation = _pos
	turrets.append(_turret)
	
func assign_turret_target(_targets :Array):
	if _is_master:
		targets = _targets
		
remotesync func _take_damage(_damage :int, _remain_hp :int):
	._take_damage(_damage, _remain_hp)
	_hit_particle.display_hit(
		"-%s" % _damage, Color.orangered, global_transform.origin
	)
	
remotesync func _dead():
	._dead()
	for _turret in turrets:
		_turret.enable = false
		
	_falling_down_rotation = 1.2 if randf() > 0 else -1.2
	
	_explode()
	
remotesync func _reset():
	._reset()
	for _turret in turrets:
		_turret.enable = true
		
	throttle = 0.0
	rotate_direction = 0.0
	
	_last_velocity = Vector3.ZERO
	_velocity = Vector3.ZERO
	
	_explosion_sfx.visible = false
	_fire_sfx.set_is_burning(false)
	
func master_moving(delta :float) -> void:
	if is_dead:
		_falling_down(delta)
		.master_moving(delta)
		return
		
	var _input_power :float = move_direction.length()
	var _is_moving :bool = _input_power > 0.1
	
	var _acc :float = (acceleration * _input_power) if _is_moving else -acceleration
	
	throttle = lerp(throttle, throttle + _acc, delta)
	throttle = clamp(throttle, 0, speed)
	
	var _move :Vector3 = -global_transform.basis.z * throttle
	_velocity = Vector3(_move.x, _velocity.y, _move.z)
	
	_ajust_altitude()
	
	var y_rotation :float = rotation_degrees.y
	var rotation_power :float = clamp(throttle * _input_power, 0, 0.5)
	.turn_spatial_pivot_to_moving(self, rotation_power, delta)
	
	rotate_direction = clamp(rotation_degrees.y - y_rotation, -1, 1)
	
	var _roll_rotation_speed :float = _input_power if _is_moving else 1.0
	rotation_degrees.z = lerp(rotation_degrees.z, rotate_direction * 45,_roll_rotation_speed * delta)
	rotation_degrees.x = 0
	
	.master_moving(delta)
	
	_last_velocity = _velocity
	
func moving(delta :float) -> void:
	.moving(delta)
	_turret_get_target()
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	throttle = _puppet_throttle
	rotate_direction = _puppet_rotate_direction
	targets = _puppet_targets
	
func _ajust_altitude():
	if translation.y < altitude:
		_velocity.y = throttle
		
	elif translation.y > altitude + 0.2:
		_velocity.y = -throttle
		
	else:
		_velocity.y = 0
		
func _falling_down(delta):
	var is_grounded :bool = is_on_floor()
	var is_below_surface :bool = translation.y < -5
	
	if is_grounded or is_below_surface:
		_explode()
		set_process(false)
		return
		
	# still flying?
	# down & rotate
	throttle = lerp(throttle, throttle + 1.5, delta)
	throttle = clamp(throttle, 0, speed)
	
	_velocity = Vector3(_last_velocity.x, -throttle, _last_velocity.z)
	rotate_y(_falling_down_rotation * delta)
	
func _explode():
	_explosion_sfx.translation = global_transform.origin
	_explosion_sfx.visible = true
	
	yield(get_tree(),"idle_frame")
	
	_sound.stream = explosions[rand_range(0, explosions.size())]
	_sound.play()
	
	if translation.y > -5:
		_explosion_sfx.emitting = true
		
	_fire_sfx.set_is_burning(true)
	
func _turret_get_target():
	var pos :int = 0
	for _turret in turrets:
		if  targets.empty() or is_dead:
			_turret.target = NodePath("")
			
		else:
			_turret.target = targets[pos]
			
			if pos < targets.size() - 1:
				pos += 1
	
