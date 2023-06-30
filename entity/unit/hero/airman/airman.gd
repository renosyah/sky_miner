extends Hero

onready var animation_tree = $AnimationTree.get("parameters/playback")

remotesync func _dead():
	._dead()
	_animation_state = "dead"
	
remotesync func _reset():
	._reset()
	_animation_state = "idle"
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	var _input_power :float = move_direction.length()
	var _is_moving :bool = _input_power > 0.1
	_animation_state = "walk" if _is_moving else "idle"
	
func moving(delta :float) -> void:
	.moving(delta)
	animation_tree.travel(_animation_state)
	
func perform_attack():
	.perform_attack()
	_animation_state = "attack_punch"






