extends BaseGameplayMp

var player_airship :AirShip

func _process(_delta):
	# test player
	if is_instance_valid(player_airship):
		_camera.translation = player_airship.translation
		
# test
func on_airship_spawned(airship :AirShip, bot :Bot):
	.on_airship_spawned(airship, bot)
	
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = airship.name
	hp_bar.enable_label = true
	hp_bar.color = Color.orange
	airship.add_child(hp_bar)
	hp_bar.update_bar(airship.hp, airship.max_hp)
	
	airship.connect("take_damage", self, "_test_on_unit_take_damage",[hp_bar])
	airship.connect("dead", self, "_test_on_cruiser_dead",[hp_bar])
	airship.connect("reset", self, "_test_on_unit_reset",[hp_bar])
	
	if airship.name == "airship_1":
		player_airship = airship
		
# test
func on_emplacement_spawned(emplacement :Emplacement, bot :Bot):
	.on_emplacement_spawned(emplacement, bot)
		
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = emplacement.name
	hp_bar.enable_label = true
	hp_bar.color = Color.orange
	emplacement.add_child(hp_bar)
	hp_bar.update_bar(emplacement.hp, emplacement.max_hp)
	
	emplacement.connect("take_damage", self, "_test_on_unit_take_damage",[hp_bar])
	emplacement.connect("dead", self, "_test_on_defence_dead",[hp_bar])
	emplacement.connect("reset", self, "_test_on_unit_reset",[hp_bar])
	
# test
func _test_on_unit_take_damage(_unit :BaseUnit, _damage :int, _hp_bar :HpBar3D):
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
# test
func _test_on_cruiser_dead(_unit :AirShip, _hp_bar :HpBar3D):
	_hp_bar.update_bar(0, _unit.max_hp)
	
# test
func _test_on_defence_dead(_unit :Emplacement, _hp_bar :HpBar3D):
	_hp_bar.update_bar(0, _unit.max_hp)
	
# test
func _test_on_unit_reset(_unit :BaseUnit, _hp_bar :HpBar3D):
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
