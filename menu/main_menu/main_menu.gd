extends Control

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	NetworkLobbyManager.connect("on_host_player_connected", self, "_on_host_player_connected")
	
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
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = NetworkServer.new()
	NetworkLobbyManager.init_lobby()

func _on_host_player_connected():
	get_tree().change_scene("res://gameplay/mp/host/gameplay.tscn")
	
