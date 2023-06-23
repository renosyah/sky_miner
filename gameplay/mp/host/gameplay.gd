extends BaseGameplayMp

onready var cruiser_1 = $cruiser
onready var cruiser_2 = $cruiser2
onready var cruiser_3 = $cruiser3

onready var cruiser_1_bot = $cruiser/bot
onready var cruiser_2_bot = $cruiser2/bot
onready var cruiser_3_bot = $cruiser3/bot
onready var bots = [cruiser_2_bot, cruiser_3_bot]

onready var turret_platform_1 = $turret_platform
onready var turret_platform_2 = $turret_platform2

onready var turret_platform_1_bot = $turret_platform/bot
onready var turret_platform_2_bot = $turret_platform2/bot

func _ready():
	test_display_hp()
	
func _process(_delta):
	cruiser_1.move_direction = _ui.get_joystick_direction()
	_camera.translation = cruiser_1.translation
	_camera.set_distance(cruiser_1.throttle * cruiser_1.speed)
	
	# test
	cruiser_1.assign_turret_target(cruiser_1_bot.get_node_path_targets())
	cruiser_2.assign_turret_target(cruiser_2_bot.get_node_path_targets())
	cruiser_3.assign_turret_target(cruiser_3_bot.get_node_path_targets())
	turret_platform_1.assign_turret_target(turret_platform_1_bot.get_node_path_targets())
	turret_platform_2.assign_turret_target(turret_platform_2_bot.get_node_path_targets())
	
# test
func test_display_hp():
	var _cruisers = [cruiser_1, cruiser_2, cruiser_3]
	for i in _cruisers:
		var cruiser :AirShip = i
		var _hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
		cruiser.add_child(_hp_bar)
		_hp_bar.update_bar(cruiser.hp, cruiser.max_hp)
		cruiser.connect("take_damage", self, "_test_on_cruiser_take_damage",[_hp_bar])
		cruiser.connect("dead", self, "_test_on_cruiser_dead",[_hp_bar])
	
		if cruiser != cruiser_1:
			_hp_bar.set_hp_bar_color(Color.red)
# test
func _test_on_enemy_airship_patrol_timeout():
	for i in bots:
		i.move_to(_map.get_random_island().translation)
		
# test
func _test_on_cruiser_take_damage(_unit, _damage, _hp_bar):
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
# test
func _test_on_cruiser_dead(_unit, _hp_bar):
	yield(get_tree().create_timer(15), "timeout")
	_unit.reset()
	_unit.translation = _map.get_random_island().translation
	_unit.translation.y = 20
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
# test
func on_map_ready():
	.on_map_ready()
	turret_platform_1.translation = _map.get_islands()[0].translation
	turret_platform_2.translation = _map.get_islands()[1].translation




