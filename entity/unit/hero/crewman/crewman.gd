tool
extends Hero

onready var _upper_body_animation_tree = $pivot/AnimationTree.get("parameters/playback")
onready var _body_animation_tree = $BodyAnimationTree.get("parameters/playback")
onready var _kinematicks = [
	$pivot/Armature/Skeleton/body,
	$pivot/Armature/Skeleton/arm_l,
	$pivot/Armature/Skeleton/arm_r,
	$pivot/Armature/Skeleton/leg_l,
	$pivot/Armature/Skeleton/leg_r
]

func _ready():
	for i in _kinematicks:
		var item :SkeletonIK = i
		item.start(false)
		
	equip_parent = $pivot/Armature/Skeleton/BoneAttachment/item_equip

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
	_animation_states["upper_body"] = _get_upper_body_animation(_is_moving)
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if _animation_states.has("body"):
		_body_animation_tree.travel(_animation_states["body"])
		
	if _animation_states.has("upper_body"):
		_upper_body_animation_tree.travel(_animation_states["upper_body"])
		
func perform_attack():
	.perform_attack()
	
	if is_instance_valid(equiped_item):
		if equiped_item is RangeWeapon:
			equiped_item.fire()
			
	_animation_states["upper_body"] = _get_attack_animation()
	
func _get_attack_animation() -> String:
	if is_instance_valid(equiped_item):
		return equiped_item.attack_animation
		
	return "attack_punch"
	
func _get_upper_body_animation(_is_moving :bool) -> String:
	if is_instance_valid(equiped_item):
		if _is_moving:
			return equiped_item.equip_animation_walk
			
		return equiped_item.equip_animation_idle
		
	if _is_moving:
		return "walk"
		
	return "idle"

