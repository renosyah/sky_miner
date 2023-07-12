extends InventoryItem
class_name RangeWeapon

const equip_animation_idle = "attack_range_weapon"
const equip_animation_walk = "attack_range_weapon"

const attack_animation = "attack_range_weapon"
const attack_bonus = 5
const attack_range = 15

onready var animation_player = $AnimationPlayer

func _ready():
	can_stack = false
	stack_total = 1
	
func fire():
	animation_player.play("firing")
