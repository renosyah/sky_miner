extends Hero

onready var _upper_body_animation_tree = $pivot/AnimationTree.get("parameters/playback")
onready var _body_animation_tree = $BodyAnimationTree.get("parameters/playback")

remotesync func _dead():
	._dead()
	_animation_states["upper_body"] = "idle"
	_animation_states["body"] = "dead"
	
remotesync func _reset():
	._reset()
	_animation_states["body"] = "idle"
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	var _input_power :float = move_direction.length()
	var _is_moving :bool = _input_power > 0.1
	
	_animation_states["body"] = "walk" if _is_moving else "idle"
	_animation_states["upper_body"] = "walk" if _is_moving else "idle"
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if _animation_states.has("body"):
		_body_animation_tree.travel(_animation_states["body"])
		
	if _animation_states.has("upper_body"):
		_upper_body_animation_tree.travel(_animation_states["upper_body"])
	
	
func perform_attack():
	.perform_attack()
	_animation_states["upper_body"] = "attack_punch"






