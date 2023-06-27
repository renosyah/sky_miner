extends Sprite3D
class_name HpBar3D

export var tag_name :String
export var level :int
export var color :Color
export var enable_label :bool

export var attach_to :NodePath
export var pos_offset :Vector3

onready var _attach_to :BaseUnit = get_node_or_null(attach_to)
onready var _viewport_hp_bar = $Viewport
onready var _2d_hp_bar = $Viewport/VBoxContainer

func _ready():
	texture = _viewport_hp_bar.get_texture()
	_2d_hp_bar.player_name(tag_name)
	_2d_hp_bar.player_level(level)
	_2d_hp_bar.show_label(enable_label)
	_2d_hp_bar.set_hp_bar_color(color)
	
func update_bar(hp, max_hp : int):
	_2d_hp_bar.update_bar(hp, max_hp)

func _process(_delta):
	if is_instance_valid(_attach_to):
		translation = _attach_to.global_transform.origin + pos_offset
