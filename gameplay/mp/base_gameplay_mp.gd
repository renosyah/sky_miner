extends Node
class_name BaseGameplayMp

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	
	setup_map()
	setup_camera()
	setup_ui()
	
	NetworkLobbyManager.set_ready()
	
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
# cameras
var _camera :FixCamera

func setup_camera():
	_camera = preload("res://assets/fix_camera/fix_camera.tscn").instance()
	add_child(_camera)
	
################################################################
# map
var _map :Map

func setup_map():
	_map = preload("res://map/map.tscn").instance()
	_map.connect("on_map_ready", self, "on_map_ready")
	add_child(_map)
	
	if is_server():
		_map.generate_islands()
		NetworkLobbyManager.argument["map_data"] = _map.map_data
	
func on_map_ready():
	pass
	
func _generate_island():
	_map.map_data = NetworkLobbyManager.argument["map_data"]
	_map.spawn_islands()
	
################################################################
# ui
var _ui :UiMp

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	add_child(_ui)
	
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
	_generate_island()
	
################################################################
# airship spawner
func spawn_airship(_data :AirshipData, _parent :Node = self):
	rpc("_spawn_airship", _data.to_dictionary(), _parent.get_path())

remotesync func _spawn_airship(_data :Dictionary, _parent_path :NodePath):
	var _airship_data :AirshipData = AirshipData.new()
	_airship_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var spawns :Array = _airship_data.spawn_airship(_parent)
	on_airship_spawned(spawns[0], spawns[1])
	
func on_airship_spawned(_airship :AirShip, _bot :Bot):
	pass
	
################################################################
# emplacement spawner
func spawn_emplacement(_data :EmplacementData, _parent :Node = self):
	rpc("_spawn_emplacement", _data.to_dictionary(), _parent.get_path())

remotesync func _spawn_emplacement(_data :Dictionary, _parent_path :NodePath):
	var _emplacement_data :EmplacementData = EmplacementData.new()
	_emplacement_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var spawns :Array = _emplacement_data.spawn_emplacement(_parent)
	on_emplacement_spawned(spawns[0], spawns[1])
	
func on_emplacement_spawned(_airship :Emplacement, _bot :Bot):
	pass
	
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	
func to_main_menu():
	get_tree().change_scene("res://menu/main_menu/main_menu.tscn")
	
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
	
func get_move_direction_with_basis_camera() -> Vector3:
	var move_direction = _ui.get_move_direction()
	var camera_basis = _camera.transform.basis
	return camera_basis.z * move_direction.z + camera_basis.x * move_direction.x
	
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

