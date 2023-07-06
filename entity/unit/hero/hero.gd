extends GroundUnit
class_name Hero

var inventories :Array = []

const hit_melee_sounds = [
	preload("res://assets/sounds/hero/hit_melee_1.wav"), 
	preload("res://assets/sounds/hero/hit_melee_2.wav"), 
	preload("res://assets/sounds/hero/hit_melee_3.wav")
]

const woods = [BaseResources.type_resource_enum.wood]
const stones = [BaseResources.type_resource_enum.iron, BaseResources.type_resource_enum.coal]

var equiped_item :InventoryItem
var equip_parent :Spatial
remotesync func _dead():
	._dead()
	_unequip_item()
	
func _unequip_item():
	if is_instance_valid(equiped_item):
		equip_parent.remove_child(equiped_item)
		equiped_item.queue_free()
		equiped_item = null
		
func moving(delta :float) -> void:
	.moving(delta)
	
	if not is_instance_valid(equip_parent):
		return
		
	if not is_instance_valid(target):
		_unequip_item()
		return
		
	if target.is_dead:
		_unequip_item()
		return
		
	if target is BaseUnit:
		# equip weapon
		pass
		
	elif target is BaseResources:
		var is_wood :bool = target.type_resource in woods
		var is_stone :bool = target.type_resource in stones
		var currently_equip :bool = is_instance_valid(equiped_item)
		
		for i in inventories:
			var item :InventoryItem = i
			if is_wood and (item is Axe):
				if currently_equip:
					if equiped_item is Axe:
						return
						
				_unequip_item()
				equiped_item = item.duplicate()
				equiped_item.visible = true
				equip_parent.add_child(equiped_item)
				
			elif is_stone and (item is PickAxe):
				if currently_equip:
					if equiped_item is PickAxe:
						return
						
				_unequip_item()
				equiped_item = item.duplicate()
				equiped_item.visible = true
				equip_parent.add_child(equiped_item)
				
			else:
				if currently_equip:
					_unequip_item()
		
	
func perform_attack():
	#.perform_attack()
	var attack_bonus :int = 0
	
	if is_instance_valid(equiped_item):
		attack_bonus = equiped_item.attack_bonus
	
	if target is BaseUnit:
		if _is_master:
			target.take_damage(attack_damage + attack_bonus)
		
	elif target is BaseResources:
		if _is_master:
			target.take_damage(attack_damage + attack_bonus)
			
	_sound.stream = hit_melee_sounds[rand_range(0, 3)]
	_sound.play()
	
