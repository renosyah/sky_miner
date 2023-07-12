extends GroundUnit
class_name Hero

var inventories :Array = []

const hit_melee_sounds = [
	preload("res://assets/sounds/hero/hit_melee_1.wav"), 
	preload("res://assets/sounds/hero/hit_melee_2.wav"), 
	preload("res://assets/sounds/hero/hit_melee_3.wav")
]

var equiped_item :InventoryItem
var equip_parent :Spatial

var _hero_spotter :HeroSpotter
var _gather_indicator :GatherIndicator
var _crosshair :Spatial

func _ready():
	_crosshair = preload("res://assets/crosshair/crosshair.tscn").instance()
	add_child(_crosshair)
	_crosshair.set_as_toplevel(true)
	
	_gather_indicator = preload("res://assets/gather_indicator/gather_indicator.tscn").instance()
	add_child(_gather_indicator)
	_gather_indicator.set_as_toplevel(true)
	
	if _check_is_master():
		_hero_spotter = preload("res://assets/utils/spotter/hero_spotter.tscn").instance()
		_hero_spotter.team = team
		_hero_spotter.ignore_body = self
		add_child(_hero_spotter)
	
remotesync func _dead():
	._dead()
	_unequip_item()
	
func _unequip_item():
	if is_instance_valid(equiped_item):
		equip_parent.remove_child(equiped_item)
		equiped_item.queue_free()
		equiped_item = null
		final_attack_range = attack_range
		
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	_check_target()
	
func moving(delta :float) -> void:
	.moving(delta)
	
	_gather_indicator.visible = false
	_crosshair.visible = false
	
	if not is_instance_valid(equip_parent):
		return
		
	if not is_instance_valid(target):
		return
		
	if target.is_dead:
		return
		
	var is_currently_equip :bool = is_instance_valid(equiped_item)
	var target_pos :Vector3 = target.global_transform.origin
	var is_align = _is_align(target_pos)
	
	if target is BaseUnit:
		_equip_weapon(is_currently_equip)
		var aim_pos = target_pos
		
		if not is_align:
			var _from_pos :Vector3 = global_transform.origin
			var _dist :float = _from_pos.distance_to(target_pos)
			var _to_pos :Vector3 = _from_pos + -global_transform.basis.z * _dist
			_to_pos.y = target_pos.y
			aim_pos = _to_pos
		
		_crosshair.visible = true
		_crosshair.translation = aim_pos
		
	elif target is BaseResources:
		_equip_tool(is_currently_equip)
		
		if is_align:
			_gather_indicator.update_indicator(target.hp, target.max_hp)
			_gather_indicator.set_icon(target.get_resource_icon())
			_gather_indicator.visible = true
			_gather_indicator.translation = target_pos
		
func perform_attack():
	final_attack_damage = attack_damage
	
	if is_instance_valid(equiped_item):
		final_attack_damage += equiped_item.attack_bonus
		
	_sound.stream = hit_melee_sounds[rand_range(0, 3)]
	_sound.play()
	
	.perform_attack()
	
func _check_target():
	target = null
	
	var _unit_targets :Array = _hero_spotter.get_alive_unit_targets()
	var _resource_targets :Array = _hero_spotter.get_alive_resource_targets()
	
	var targets :Array = _unit_targets + _resource_targets
	if targets.empty():
		return
		
	if not _unit_targets.empty():
		_get_closes_target(_unit_targets)
		return
		
	if not _resource_targets.empty():
		_get_closes_target(_resource_targets)
	
func _get_closes_target(_targets :Array):
	var from :Vector3 = global_transform.origin
	var final_target = _targets[0]
	
	for new_target in _targets:
		if new_target.is_dead:
			continue
			
		var dis_1 = from.distance_squared_to(final_target.global_transform.origin)
		var dis_2 = from.distance_squared_to(new_target.global_transform.origin)
		
		if dis_2 < dis_1:
			final_target = new_target
			
	target = final_target
	
func _equip_weapon(_currently_equip: bool):
	for i in inventories:
		var item :InventoryItem = i
		if item is RangeWeapon:
			if _currently_equip:
				if equiped_item is RangeWeapon:
					return
					
				else:
					_unequip_item()
					
			equiped_item = item.duplicate()
			equip_parent.add_child(equiped_item)
			equiped_item.equip()
			final_attack_range = equiped_item.attack_range
			return
			
	if _currently_equip:
		_unequip_item()
		
func _equip_tool(_currently_equip: bool):
	var is_wood :bool = target.type_resource in BaseResources.woods
	var is_stone :bool = target.type_resource in BaseResources.stones
	
	for i in inventories:
		var item :InventoryItem = i
		if is_wood and (item is Axe):
			if _currently_equip:
				if equiped_item is Axe:
					return
					
				else:
					_unequip_item()
					
			equiped_item = item.duplicate()
			equip_parent.add_child(equiped_item)
			equiped_item.equip()
			final_attack_range = equiped_item.attack_range
			return
			
		if is_stone and (item is PickAxe):
			if _currently_equip:
				if equiped_item is PickAxe:
					return
					
				else:
					_unequip_item()
					
			equiped_item = item.duplicate()
			equip_parent.add_child(equiped_item)
			equiped_item.equip()
			final_attack_range = equiped_item.attack_range
			return
		
	if _currently_equip:
		_unequip_item()
		
