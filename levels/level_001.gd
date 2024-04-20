extends Node3D

const PLAYER = preload("res://controllers/player.tscn")
const ENEMY = preload("res://enemies/enemy.tscn")

@onready var menu: Menu = $Menu as Menu

var _enemy_queue: int = 0
var _enemy_count: int = 0


func _ready() -> void:
	randomize()
	
	Lobby.server_disconnected.connect(server_disconnected)

	# signals are only emitted on server
	Lobby.player_connected.connect(add_player)
	Lobby.player_disconnected.connect(remove_player)


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	get_tree().call_group("enemies", "approach_closest_player", get_tree().get_nodes_in_group("players"))
	if _enemy_queue > 0:
		spawn_enemy()


func add_player(id: int) -> void:
	var player := PLAYER.instantiate() as Player
	player.name = str(id)
	add_child(player)
	_enemy_queue += 1


func spawn_enemy() -> void:
	var enemy_spawn_areas := get_tree().get_nodes_in_group("enemy_spawn")
	var empty_enemy_spawn_areas := enemy_spawn_areas.filter(func(area: SpawnArea) -> bool: return not area.has_overlapping_bodies()) as Array
	if empty_enemy_spawn_areas.is_empty():
		print("Waiting for free space to spawn enemy...")
		return
	if current_enemies() > 400:
		print("Too many enemies on the field")
		return
	empty_enemy_spawn_areas.shuffle()
	var spawn_area := empty_enemy_spawn_areas.front() as SpawnArea
	var enemy := ENEMY.instantiate() as Enemy
	_enemy_queue -= 1
	_enemy_count += 1
	enemy.name = str("enemy%s" % _enemy_count)
	enemy.destroyed.connect(_on_enemy_destroyed)
	enemy.position = spawn_area.collision_shape_3d.global_position
	add_child(enemy)
	update_enemy_count.rpc()


@rpc("call_local")
func update_enemy_count() -> void:
	var player := get_tree().get_nodes_in_group("players").filter(func(this: Player) -> bool: return this.is_multiplayer_authority()).front() as Player
	if player:
		player.update_enemies_count(current_enemies())


func current_enemies() -> int:
	return get_tree().get_nodes_in_group("enemies").size()


func remove_player(peer_id: int) -> void:
	for player: Player in get_tree().get_nodes_in_group("players"):
		if player.name == str(peer_id):
			player.queue_free()


func server_disconnected() -> void:
	menu.open()
	
	for player: Player in get_tree().get_nodes_in_group("players"):
		player.queue_free()


func _on_enemy_destroyed() -> void:
	update_enemy_count.rpc()
	_enemy_queue += 2
