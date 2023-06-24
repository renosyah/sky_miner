extends Sprite3D
class_name HpBar3D

export var tag_name :String
export var color :Color
export var enable_label :bool

onready var _player_name = $Viewport/VBoxContainer/name
onready var _viewport_hp_bar = $Viewport
onready var _2d_hp_bar = $Viewport/VBoxContainer/hp_bar

func _ready():
	texture = _viewport_hp_bar.get_texture()
	_2d_hp_bar.show_label(enable_label)
	_2d_hp_bar.set_hp_bar_color(color)
	_player_name.text = tag_name
	
func update_bar(hp, max_hp : int):
	_2d_hp_bar.update_bar(hp, max_hp)
