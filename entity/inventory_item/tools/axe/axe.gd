extends InventoryItem
class_name Axe

const equip_animation_idle = "idle"
const equip_animation_walk = "walk"

const attack_animation = "gather_wood"
const attack_bonus = 15
const attack_range = 3

func _ready():
	can_stack = false
	stack_total = 1
