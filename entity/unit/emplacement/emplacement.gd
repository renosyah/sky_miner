extends BaseUnit
class_name Emplacement

const explosions = [
	preload("res://assets/sounds/explosions/explosion_1.wav"),
	preload("res://assets/sounds/explosions/explosion_2.wav"),
	preload("res://assets/sounds/explosions/explosion_3.wav")
]

export var color_coat :Color
export var turret_positions :Array

var turrets :Array = []
var targets :Array

var _explosion_sfx :CPUParticles
var _fire_sfx :Spatial

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not enable_network:
		return
		
	if _is_master and _is_online:
		rset_unreliable("_puppet_targets", targets)
		
# multiplayer func
puppet var _puppet_targets :Array

func _ready():
	enable_gravity = false
	_explosion_sfx = preload("res://addons/explosion/quick_explosion.tscn").instance()
	add_child(_explosion_sfx)
	_explosion_sfx.visible = false
	_explosion_sfx.set_as_toplevel(true)
	
	_fire_sfx = preload("res://assets/visual_effect/fire/fire.tscn").instance()
	add_child(_fire_sfx)

func assign_turret_position(_turret :Turret, _pos :Vector3):
	_turret.enable = (not is_dead)
	add_child(_turret)
	_turret.is_master = _check_is_master()
	_turret.translation = _pos
	turrets.append(_turret)
	
func assign_turret_target(_targets :Array):
	if _is_master:
		targets = _targets
		
remotesync func _dead():
	._dead()
	for _turret in turrets:
		_turret.enable = false
		
	_explode()
		
remotesync func _reset():
	._reset()
	for _turret in turrets:
		_turret.enable = true
		
	_explosion_sfx.visible = false
	_fire_sfx.set_is_burning(false)
	
func moving(delta :float) -> void:
	.moving(delta)
	_turret_get_target()
	
func master_moving(_delta :float) -> void:
	# static unit, no move
	#.master_moving(_delta)
	pass
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	if not enable_network or not _puppet_ready:
		return
		
	targets = _puppet_targets
	
func _turret_get_target():
	var pos :int = 0
	for _turret in turrets:
		if targets.empty():
			_turret.target = NodePath("")
			
		else:
			_turret.target = targets[pos]
			
			if pos < targets.size() - 1:
				pos += 1
	
func _explode():
	_explosion_sfx.translation = global_transform.origin
	_explosion_sfx.visible = true
	
	yield(get_tree(),"idle_frame")
	
	_sound.stream = explosions[rand_range(0, explosions.size())]
	_sound.play()
	
	if translation.y > -5:
		_explosion_sfx.emitting = true
		
	_fire_sfx.set_is_burning(true)









