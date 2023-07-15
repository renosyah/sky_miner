extends Node
class_name BaseGameplay

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	setup_parents()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	on_exit_game_session()
	
################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_host_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "connection_closed")
	NetworkLobbyManager.connect("all_player_ready", self, "all_player_ready")
	NetworkLobbyManager.connect("on_player_disconnected", self, "on_player_disconnected")
	
func on_player_disconnected(_player_network :NetworkPlayer):
	pass
	
func connection_closed():
	to_main_menu()
	
func on_host_disconnected():
	to_main_menu()
	
func all_player_ready():
	Global.dismiss_transition()
	
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	
func to_main_menu():
	Global.change_scene("res://menu/main_menu/main_menu.tscn")
	
################################################################
# holders
var _hero_parent :Node
var _airship_parent :Node
var _defence_parent :Node

func setup_parents():
	_hero_parent = Node.new()
	_hero_parent.name = "hero_parent"
	add_child(_hero_parent)
	
	_airship_parent = Node.new()
	_airship_parent.name = "airship_parent"
	add_child(_airship_parent)
	
	_defence_parent = Node.new()
	_defence_parent.name = "defence_parent"
	add_child(_defence_parent)
	
################################################################
# hero spawner
func spawn_heroes(_datas :Array, _parent :Node = _hero_parent):
	if not is_server():
		return
		
	var _datas_dicts :Array = []
	for i in _datas:
		_datas_dicts.append(i.to_dictionary())
		
	rpc("_spawn_heroes", _datas_dicts, _parent.get_path())
	
remotesync func _spawn_heroes(_datas :Array, _parent_path :NodePath):
	for data in _datas:
		_spawn_hero(data, _parent_path)
	
func spawn_hero(_data :HeroData, _parent :Node = _hero_parent):
	if not is_server():
		return
		
	rpc("_spawn_hero", _data, _parent.get_path())
	
remotesync func _spawn_hero(_data :Dictionary, _parent_path :NodePath):
	var _hero_data :HeroData = HeroData.new()
	_hero_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var hero :Hero = _hero_data.spawn_hero(_parent)
	
	for inventory in _hero_data.inventories:
		var item :InventoryItemData = inventory
		var item_spawn :InventoryItem = item.spawn_item(hero)
		hero.inventories.append(item_spawn)
		item_spawned(item, item_spawn)
	
	on_hero_spawned(_hero_data, hero)
	
func on_hero_spawned(data :HeroData, hero :Hero):
	pass
	
################################################################
# airship spawner
func spawn_airships(_datas :Array, _parent :Node = _airship_parent):
	if not is_server():
		return
		
	var _datas_dicts :Array = []
	for i in _datas:
		_datas_dicts.append(i.to_dictionary())
		
	rpc("_spawn_airships", _datas_dicts, _parent.get_path())

remotesync func _spawn_airships(_datas :Array, _parent_path :NodePath):
	for data in _datas:
		_spawn_airship(data, _parent_path)
	
func spawn_airship(_data :AirshipData, _parent :Node = _airship_parent):
	if not is_server():
		return
		
	rpc("_spawn_airship", _data.to_dictionary(), _parent.get_path())

remotesync func _spawn_airship(_data :Dictionary, _parent_path :NodePath):
	var _airship_data :AirshipData = AirshipData.new()
	_airship_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var airship :AirShip = _airship_data.spawn_airship(_parent)
	airship.look_at(Vector3.ZERO + Vector3(0,0, airship.altitude), Vector3.UP)
	on_airship_spawned(_airship_data, airship)
	
func on_airship_spawned(data :AirshipData, airship :AirShip):
	pass
	
################################################################
# emplacement spawner
func spawn_emplacements(_datas :Array, _parent :Node = _defence_parent):
	if not is_server():
		return
		
	var _datas_dicts :Array = []
	for i in _datas:
		_datas_dicts.append(i.to_dictionary())
		
	rpc("_spawn_emplacements", _datas_dicts, _parent.get_path())
	
remotesync func _spawn_emplacements(_datas :Array, _parent_path :NodePath):
	for data in _datas:
		_spawn_emplacement(data, _parent_path)
	
func spawn_emplacement(_data :EmplacementData, _parent :Node = _defence_parent):
	if not is_server():
		return
		
	rpc("_spawn_emplacement", _data.to_dictionary(), _parent.get_path())
	
remotesync func _spawn_emplacement(_data :Dictionary, _parent_path :NodePath):
	var _emplacement_data :EmplacementData = EmplacementData.new()
	_emplacement_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var emplacement :Emplacement = _emplacement_data.spawn_emplacement(_parent)
	on_emplacement_spawned(_emplacement_data, emplacement)
	
func on_emplacement_spawned(data :EmplacementData, emplacement :Emplacement):
	pass
	
################################################################
# items spawner
func spawn_items(_items :Array, _parent :Node = self):
	if not is_server():
		return
		
	var _data_dicts :Array = []
	for i in _items:
		var _item :InventoryItemData = i
		_data_dicts.append(_item.to_dictionary())
		
	rpc("_spawn_items", _data_dicts, _parent.get_path())
	
remotesync func _spawn_items(_datas :Array, _parent_path :NodePath):
	for i in _datas:
		_spawn_item(i, _parent_path)
	
func spawn_item(_item :InventoryItemData, _parent :Node = self):
	if not is_server():
		return
		
	rpc("_spawn_item", _item.to_dictionary(), _parent.get_path())
	
remotesync func _spawn_item(_data :Dictionary, _parent_path :NodePath):
	var _item_data :InventoryItemData = InventoryItemData.new()
	_item_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var _item :InventoryItem = _item_data.spawn_item(_parent)
	item_spawned(_item_data, _item)
	
func item_spawned(_data :InventoryItemData, _item :InventoryItem):
	pass
	
func sync_dropped_item_position(item :InventoryItem):
	rpc("_sync_dropped_item_position", item.get_path(), item.translation)
	
remotesync func _sync_dropped_item_position(item_path :NodePath, to :Vector3):
	var item :InventoryItem = get_node_or_null(item_path)
	if not is_instance_valid(item):
		return
		
	item.translation = to
	
################################################################
# utils code
func get_players_positions(players :Array) -> Array:
	var pos :Array = []
	for player in players:
		if player is BaseUnit:
			pos.append(player.global_transform.origin)
			
	return pos
	
func get_avg_position(list_pos :Array, y :float = 0) -> Vector3:
	var pos :Vector3 = Vector3.ZERO
	var pos_len = list_pos.size()
	for i in list_pos:
		pos += i
		
	pos = pos / pos_len
	pos.y = y
	return pos
	
func get_closes(bodies :Array, from :Vector3) -> BaseUnit:
	if bodies.empty():
		return null
		
	var default :BaseUnit = bodies[0]
	for i in bodies:
		var dis_1 = from.distance_squared_to(default.global_transform.origin)
		var dis_2 = from.distance_squared_to(i.global_transform.origin)
		
		if dis_2 < dis_1:
			default = i
		
	return default
	
################################################################
# network utils code
func is_server():
	if not is_network_on():
		return false
		
	if not get_tree().is_network_server():
		return false
		
	return true
	
func is_network_on() -> bool:
	if not get_tree().network_peer:
		return false
		
	if get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
		
	return true
	
################################################################


