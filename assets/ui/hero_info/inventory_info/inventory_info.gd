extends MarginContainer
class_name InventoryInfo

export var icon :String
export var total :int
export var color: Color

onready var _icon = $icon
onready var _total = $total
onready var _border = $border

func _ready():
	_icon.texture = load(icon)
	_total.text = "%s" % total
	_border.modulate = color
