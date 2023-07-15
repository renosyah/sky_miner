extends Control

var quick_play :bool = false
var showcase :bool = false
onready var server_browser = $CanvasLayer/Control/server_browser

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	NetworkLobbyManager.connect("on_host_player_connected", self, "_on_player_connected")
	NetworkLobbyManager.connect("on_client_player_connected", self, "_on_player_connected")
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	get_tree().quit()
	
func _on_play_pressed():
	quick_play = true
	_on_host_pressed()

func _on_player_connected():
	if quick_play:
		Global.change_scene("res://gameplay/mp/host/gameplay.tscn", false)
		return
		
	if showcase:
		Global.change_scene("res://gameplay/showcase/host/gameplay.tscn", false)
		return
		
	Global.change_scene("res://menu/lobby/lobby.tscn")
	
func _on_host_pressed():
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = NetworkServer.new()
	NetworkLobbyManager.init_lobby()

func _on_join_pressed():
	server_browser.visible = true
	server_browser.start_finding()

func _on_server_browser_on_join(info):
	var config :NetworkClient = NetworkClient.new()
	config.ip = info["ip"]
	
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = config
	NetworkLobbyManager.init_lobby()
	
	
func _on_showcase_pressed():
	showcase = true
	_on_host_pressed()


