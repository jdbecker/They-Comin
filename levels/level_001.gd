extends Node3D

const PLAYER = preload("res://controllers/player.tscn")
const ENEMY = preload("res://enemies/enemy.tscn")

const MAX_ENEMIES = 200

@onready var menu: Menu = $Menu as Menu
@onready var arena_area: Area3D = $ArenaArea as Area3D

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
	get_tree().call_group("enemies", "approach_closest_player", get_tree().get_nodes_in_group("players").filter(func(player: Player)-> bool: return arena_area.get_overlapping_bodies().find(player) != -1 ))
	if _enemy_queue > 0:
		spawn_enemy()


func add_player(id: int) -> void:
	var player := PLAYER.instantiate() as Player
	player.name = str(id)
	player.died.connect(_on_player_died)
	player.position.y = 34
	add_child(player)


func spawn_enemy() -> void:
	var enemy_spawn_areas := get_tree().get_nodes_in_group("enemy_spawn")
	var empty_enemy_spawn_areas := enemy_spawn_areas.filter(func(area: SpawnArea) -> bool: return not area.has_overlapping_bodies()) as Array
	if empty_enemy_spawn_areas.is_empty():
		print("Waiting for free space to spawn enemy...")
		return
	if current_enemies() >= MAX_ENEMIES:
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
	update_enemy_count.rpc(current_enemies())


@rpc("call_local")
func update_enemy_count(count: int) -> void:
	var player := get_tree().get_nodes_in_group("players").filter(func(this: Player) -> bool: return this.is_multiplayer_authority()).front() as Player
	if player:
		player.update_enemies_count(count)


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


func reset() -> void:
	if not is_multiplayer_authority(): return
	_enemy_queue = 0
	get_tree().call_group("enemies", "queue_free")
	update_enemy_count.rpc(0)


func _on_enemy_destroyed(by: int) -> void:
	update_enemy_count.rpc(current_enemies())
	var player := get_tree().get_nodes_in_group("players").filter(func(this: Player) -> bool: return this.name == str(by)).front() as Player
	if player:
		player.add_kill.rpc_id(by)
	_enemy_queue += 2


func _on_player_died() -> void:
	if not is_multiplayer_authority(): return
	await arena_area.body_exited
	if not arena_area.has_overlapping_bodies():
		reset()
	else:
		print("Not resetting because these players are still in play:")
		for body in arena_area.get_overlapping_bodies():
			print(body)


func _on_arena_area_body_entered(body: Node3D) -> void:
	if not is_multiplayer_authority(): return
	var player := body as Player
	if player and _enemy_queue <= 0 and current_enemies() <= 0:
		print("A player has entered the arena!")
		_enemy_queue = 1
