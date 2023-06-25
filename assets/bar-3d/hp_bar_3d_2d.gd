extends HBoxContainer

onready var _level = $MarginContainer/level
onready var _name = $VBoxContainer/name
onready var _hp_bar = $VBoxContainer/hp_bar

func player_level(_lvl :int):
	_level.text = str(_lvl)
	
func player_name(tag_name :String):
	_name.text = " %s" % tag_name
	
func set_hp_bar_color(color :Color):
	_hp_bar.set_hp_bar_color(color)
	
func show_label(enable_label :bool):
	_hp_bar.show_label(enable_label)
	
func update_bar(hp, max_hp : int):
	_hp_bar.update_bar(hp, max_hp)
