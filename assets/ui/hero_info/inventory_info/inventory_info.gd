extends Control
class_name InventoryInfo

export var icon :String
export var total :int
export var color: Color

onready var _icon = $MarginContainer/icon
onready var _total = $MarginContainer/total
onready var _border = $MarginContainer/border

func _ready():
	_icon.texture = load(icon)
	_total.text = "%s" % total
	_border.modulate = color
