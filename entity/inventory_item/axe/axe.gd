extends InventoryItem
class_name Axe

const attack_animation = "gather_wood"
const attack_bonus = 5
const attack_range = 3

onready var glowing = $glowing

func _ready():
	glowing.visible = enable_pickup

func picked_up(_by):
	.picked_up(_by)
	
	glowing.visible = false
	
func drop(_to :Node):
	.drop(_to)
	
	glowing.visible = true
	
