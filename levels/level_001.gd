extends Node3D

const PLAYER = preload("res://controllers/player.tscn")

@onready var menu: Menu = $Menu as Menu
#@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


#func _enter_tree() -> void:
	#var spawner := $MultiplayerSpawner as MultiplayerSpawner
	#spawner.spawn_function = _spawn_player
	#
	#multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _ready() -> void:
	# signals are only emitted on server
	Lobby.player_connected.connect(add_player)
	Lobby.player_disconnected.connect(remove_player)
	Lobby.server_disconnected.connect(server_disconnected)


func add_player(id: int) -> void:
	var player := PLAYER.instantiate()
	player.name = str(id)
	add_child(player)


#func add_player(peer_id: int) -> void:
		#multiplayer_spawner.spawn(peer_id)


func remove_player(peer_id: int) -> void:
	for player: Player in get_tree().get_nodes_in_group("players"):
		if player.name == str(peer_id):
			player.queue_free()


func server_disconnected() -> void:
	menu.open()
	
	for player: Player in get_tree().get_nodes_in_group("players"):
		player.queue_free()
