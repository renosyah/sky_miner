extends InventoryItem
class_name PickAxe

const attack_animation = "gather_stone"
const attack_bonus = 15
const attack_range = 3

func _ready():
	can_stack = false
	stack_total = 1
