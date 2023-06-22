extends BaseGameplayMp

onready var cruiser = $cruiser
onready var bots = [$cruiser2/bot, $cruiser3/bot]
onready var islands = _map.get_islands()

func _process(delta):
	cruiser.move_direction = _ui.get_joystick_direction()
	_camera.translation = cruiser.translation
	_camera.set_distance(cruiser.throttle * cruiser.speed)
	
func _on_enemy_airship_patrol_timeout():
	var island :FloatingIsland = islands[rand_range(0, islands.size())]
	for i in bots:
		i.move_to(island.translation)
