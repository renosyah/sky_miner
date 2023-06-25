extends VBoxContainer

onready var _hp_bar = $hp_bar
onready var _name = $name

func player_name(tag_name :String):
	_name.text = tag_name
	
func set_hp_bar_color(color :Color):
	_hp_bar.set_hp_bar_color(color)
	
func show_label(enable_label :bool):
	_hp_bar.show_label(enable_label)
	
func update_bar(hp, max_hp : int):
	_hp_bar.update_bar(hp, max_hp)
