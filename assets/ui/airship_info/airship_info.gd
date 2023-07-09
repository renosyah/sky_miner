extends HBoxContainer
class_name AirshipInfo

const turret_potrait_scene = preload("res://assets/ui/airship_info/turret_info/turret_potrait.tscn")

onready var _icon = $airship_potrait/icon

onready var _border = $airship_potrait/border
onready var _turret_holder = $turrets

onready var respawn_indicator = $airship_potrait/respawn_indicator
onready var respawn_timer = $airship_potrait/respawn_timer


func display_respawn_cooldown(time :float):
	respawn_indicator.value = time
	respawn_indicator.max_value = time
	respawn_timer.wait_time = time
	respawn_timer.start()
	set_process(true)
	
func _process(delta):
	respawn_indicator.value = respawn_timer.time_left
	
func _on_respawn_timer_timeout():
	set_process(false)
	
func display_info(_ic :String, _val :Color):
	_icon.texture = load(_ic)
	_border.modulate = _val
	
func display_turrets(airship :AirShip, _val :Color):
	for i in _turret_holder.get_children():
		_turret_holder.remove_child(i)
		i.queue_free()
		
	for i in airship.turrets:
		var turret :Turret = i
		var turret_info :TurretPotrait = turret_potrait_scene.instance()
		turret_info.icon = turret.icon
		turret_info.turret_path = turret.get_path()
		turret_info.color = _val
		_turret_holder.add_child(turret_info)




















