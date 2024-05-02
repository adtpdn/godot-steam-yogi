extends Node2D

var lobby_id = 0
@onready var peer = SteamMultiplayerPeer.new()

@onready var ms = $MultiplayerSpawner

func _ready():
	ms.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	open_loby_list()

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

func _on_button_pressed():
	# multiplayer type public
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	# loopback to private
	multiplayer.multiplayer_peer = peer
	ms.spawn("res://scenes/map.tscn")
	$CanvasLayer/Host.hide()
	$CanvasLayer/LobbyContainer/Lobbies.hide()
	$CanvasLayer/Refresh.hide()

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	$CanvasLayer/Host.hide()
	$CanvasLayer/LobbyContainer/Lobbies.hide()
	$CanvasLayer/Refresh.hide()

func _on_lobby_created(_connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, name, str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)
		print(Steam.getPersonaName())

func open_loby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, name)
		var mem_count = Steam.getNumLobbyMembers(lobby)
		
		var btn = Button.new()
		btn.set_text(str(lobby_name,"| Player Count: ", mem_count))
		btn.set_size(Vector2(100,5))
		btn.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		
		$CanvasLayer/LobbyContainer/Lobbies.add_child(btn)

func _on_refresh_pressed():
	if $CanvasLayer/LobbyContainer/Lobbies.get_child_count() > 0:
		for n in $CanvasLayer/LobbyContainer/Lobbies.get_children():
			n.queue_free()
	open_loby_list()
