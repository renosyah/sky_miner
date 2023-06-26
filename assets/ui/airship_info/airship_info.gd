extends HBoxContainer
class_name AirshipInfo

const turret_potrait_scene = preload("res://assets/ui/airship_info/turret_info/turret_potrait.tscn")

onready var _icon = $airship_potrait/icon
onready var _name = $VBoxContainer/name

onready var _bg = $airship_potrait/bg
onready var _border = $airship_potrait/border

onready var _turret_holder = $VBoxContainer/HBoxContainer

func display_info(_nm :String, _ic :String, _val :Color):
	_icon.texture = load(_ic)
	_name.text = _nm
	#_bg.modulate = _val
	_border.modulate = _val
	
func display_turrets(data, airship, _val :Color):
	for i in _turret_holder.get_children():
		_turret_holder.remove_child(i)
		i.queue_free()
		
	var _turrets = []
	for i in range(data.turrets.size()):
		_turrets.append({
			"icon" : data.turrets[i].entity_icon,
			"turret_path" : airship.turrets[i].get_path(),
		})
		
	for i in _turrets:
		var turret :TurretPotrait = turret_potrait_scene.instance()
		turret.icon = i["icon"]
		turret.turret_path = i["turret_path"]
		turret.color = _val
		_turret_holder.add_child(turret)



















