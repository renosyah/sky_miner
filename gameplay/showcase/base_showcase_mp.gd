extends BaseGameplay
class_name ShowCaseGameplayMP

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_camera()
	setup_sound()
	setup_ui()
	
	NetworkLobbyManager.set_ready()
	
################################################################
# cameras
var _camera :FixCamera

func setup_camera():
	_camera = preload("res://assets/utils/fix_camera/fix_camera.tscn").instance()
	add_child(_camera)
	_camera.translation = Vector3(0, 20, 0)
	
################################################################
# ui
var _ui :UiShowCase

func setup_ui():
	_ui = preload("res://gameplay/showcase/ui/ui.tscn").instance()
	add_child(_ui)
	
################################################################
# sounds
var _sound :AudioStreamPlayer

const pickup_item_sounds = [
	preload("res://assets/sounds/coin/coin_1.wav"),
	preload("res://assets/sounds/coin/coin_2.wav"),
	preload("res://assets/sounds/coin/coin_3.wav")
]

func setup_sound():
	_sound = AudioStreamPlayer.new()
	add_child(_sound)
	
################################################################
var player_hero :Hero

# hero spawner
func on_hero_spawned(data :HeroData, hero :Hero):
	.on_hero_spawned(data, hero)
	
	var is_player = (data.node_name == "player_%s" % NetworkLobbyManager.get_id())
	var is_same_team = (hero.team == 1)
	
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = data.entity_name
	hp_bar.level = data.level
	hp_bar.enable_label = true
	hp_bar.color = Color.green if is_player else (Color.blue if is_same_team else Color.red)
	hp_bar.attach_to = hero.get_path()
	hp_bar.pos_offset = Vector3(0,3,0)
	add_child(hp_bar)
	hp_bar.update_bar(hero.hp, hero.max_hp)
	hp_bar.visible = false
	
	hero.connect("take_damage", self, "on_unit_take_damage",[hp_bar])
	hero.connect("dead", self, "on_hero_dead",[hp_bar])
	hero.connect("reset", self, "on_hero_reset",[hp_bar])
	hero.enable_network = true
	
	if is_player:
		player_hero = hero
		player_hero.visible = true
		player_hero.enable_crosshair = true
		
		_ui.hero_info.display_info(data.entity_icon, data.color_coat)
		_ui.hero_info.display_inventory(player_hero.inventories, data.color_coat)
		
		var _highlight = preload("res://assets/unit_highlight/unit_highlight.tscn").instance()
		player_hero.add_child(_highlight)
		_highlight.scale = Vector3(1.5, 1, 1.5)
		_highlight.translation.y = -0.5
		
################################################################
# unit signals handler
func on_unit_take_damage(_unit :BaseUnit, _damage :int, hp_bar :HpBar3D):
	hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
func on_hero_dead(unit :Hero, hp_bar :HpBar3D):
	hp_bar.update_bar(0, unit.max_hp)
	hp_bar.visible = false
	
	for item in unit.inventories:
		if item is InventoryItem:
			item.drop(self)
			
	unit.reset(false)
	
func on_hero_reset(unit :Hero, hp_bar :HpBar3D):
	hp_bar.update_bar(unit.hp, unit.max_hp)
	hp_bar.visible = true
	
# items spawner
func item_spawned(_data :InventoryItemData, _item :InventoryItem):
	.item_spawned(_data, _item)
	
	_item.connect("picked_up",self, "on_item_picked_up", [_data])
	_item.connect("droped", self, "on_item_dropped", [_data])

func on_item_picked_up(_item :InventoryItem, by :Hero, _item_data :InventoryItemData):
	if by == player_hero:
		_sound.stream = pickup_item_sounds[rand_range(0, pickup_item_sounds.size())]
		_sound.play()
		
		_ui.hero_info.display_inventory(player_hero.inventories, player_hero.color_coat)
	
func on_item_dropped(item :InventoryItem, from :Hero, _item_data :InventoryItemData):
	if from == player_hero:
		_ui.hero_info.display_inventory(player_hero.inventories, player_hero.color_coat)
		sync_dropped_item_position(item)
	
################################################################
# proccess
func _process(delta):
	if not is_instance_valid(player_hero):
		return
		
	player_hero.move_direction = _ui.get_joystick_direction()
	_camera.interpolate_translation(player_hero.translation, delta)
	_camera.set_distance(10)
	_camera.set_angle(-55)
























