extends InventoryItem

onready var glowing = $glowing

func _ready():
	glowing.visible = enable_pickup

func picked_up(_by):
	.picked_up(_by)
	
	glowing.visible = false
	
func drop(_to :Node):
	.drop(_to)
	
	glowing.visible = true
	
