extends MarginContainer

onready var _level = $HBoxContainer/MarginContainer/level
onready var _name = $HBoxContainer/VBoxContainer/name
onready var _hp_bar = $HBoxContainer/VBoxContainer/hp_bar

onready var _bg = $HBoxContainer/MarginContainer/bg
onready var _border = $HBoxContainer/MarginContainer/border

func player_level(_lvl :int):
	_level.text = str(_lvl)
	
func player_name(tag_name :String):
	_name.text = " %s" % tag_name
	
func set_hp_bar_color(color :Color):
	_hp_bar.set_hp_bar_color(color)
	_bg.modulate = color
	_border.modulate = color
	
func show_label(enable_label :bool):
	_hp_bar.show_label(enable_label)
	
func update_bar(hp, max_hp : int):
	_hp_bar.update_bar(hp, max_hp)
