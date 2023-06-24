extends BaseUnit
class_name Emplacement

export var color_coat :Color
export var turret_positions :Array

var turrets :Array = []
var targets :Array

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_targets", targets)
		
# multiplayer func
puppet var _puppet_targets :Array

func assign_turret_position(_turret :Turret, _pos :Vector3):
	add_child(_turret)
	_turret.is_master = _check_is_master()
	_turret.translation = _pos
	turrets.append(_turret)
	
func assign_turret_target(_targets :Array):
	if _is_master:
		targets = _targets
		
func moving(delta :float) -> void:
	.moving(delta)
	_turret_get_target()
	
func master_moving(_delta :float) -> void:
	# static unit, no move
	#.master_moving(_delta)
	pass
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	targets = _puppet_targets
	
func _turret_get_target():
	var pos :int = 0
	for _turret in turrets:
		if  targets.empty() or is_dead:
			_turret.target = NodePath("")
			
		else:
			_turret.target = targets[pos]
			
			if pos < targets.size() - 1:
				pos += 1
	
