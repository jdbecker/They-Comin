extends Node3D

const PLAYER = preload("res://controllers/player.tscn")
const ENEMY = preload("res://enemies/enemy.tscn")

const MAX_ENEMIES = 200

@onready var menu: Menu = $Menu as Menu
@onready var arena_area: Area3D = $PlayerArenaArea as Area3D
@onready var enemy_arena_area: Area3D = $EnemyArenaArea
@onready var enemy_pathfinding_update_timer: Timer = $EnemyPathfindingUpdateTimer as Timer
@onready var window: EntryWindow = $Window as EntryWindow

var _enemy_queue: int = 0
var _enemy_count: int = 0
var _wave: int = 0


func _ready() -> void:
	randomize()
	
	Lobby.server_disconnected.connect(server_disconnected)

	# signals are only emitted on server
	Lobby.player_connected.connect(add_player)
	Lobby.player_disconnected.connect(remove_player)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("interact"):
		window.toggle()


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	if _enemy_queue > 0:
		spawn_enemy()


func add_player(id: int) -> void:
	var player := PLAYER.instantiate() as Player
	player.name = str(id)
	player.cheat_queue_wave.connect(func() -> void: _enemy_queue += 36)
	player.position.y = 34
	add_child(player)


func spawn_enemy() -> void:
	var enemy_spawn_areas := get_tree().get_nodes_in_group("enemy_spawn")
	var empty_enemy_spawn_areas := enemy_spawn_areas.filter(func(area: SpawnArea) -> bool: return not area.has_overlapping_bodies()) as Array
	if empty_enemy_spawn_areas.is_empty():
		print("Waiting for free space to spawn enemy...")
		return
	if current_enemies() >= MAX_ENEMIES:
		#print("Too many enemies on the field")
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


func current_players() -> int:
	return get_tree().get_nodes_in_group("players").size()


func alive_players() -> int:
	return arena_area.get_overlapping_bodies().size()


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
	_wave = 0
	get_tree().call_group("enemies", "queue_free")
	update_enemy_count.rpc(0)
	window.open()


func _on_enemy_destroyed(by: int) -> void:
	var player := get_tree().get_nodes_in_group("players").filter(func(this: Player) -> bool: return this.name == str(by)).front() as Player
	if player:
		player.add_kill.rpc_id(by)


func update_enemies() -> void:
	var remaining_enemies := current_enemies()
	update_enemy_count.rpc(remaining_enemies)
	if remaining_enemies <= 0 and alive_players() >= 1:
		window.open()
		await get_tree().create_timer(8).timeout
		start_wave()


func _on_arena_area_body_exited(body: Node3D) -> void:
	if not is_multiplayer_authority(): return
	var player := body as Player
	if player and not arena_area.has_overlapping_bodies():
		reset()


func _on_arena_area_body_entered(body: Node3D) -> void:
	if not is_multiplayer_authority(): return
	var player := body as Player
	if player:
		var players_outside_arena := current_players() - arena_area.get_overlapping_bodies().size()
		if players_outside_arena == 0:
			start_wave()
		else:
			print("Waiting on %s players before starting wave..." % players_outside_arena)


func _on_enemy_pathfinding_update_timer_timeout() -> void:
	if not is_multiplayer_authority(): return
	var players: Array = get_tree().get_nodes_in_group("players")
	var active_players: Array = players.filter(func(player: Player)-> bool:
		return arena_area.get_overlapping_bodies().find(player) != -1 )
	var player_coords: Array = active_players.map(func(player: Player) -> Vector3: return player.global_transform.origin)
	get_tree().call_group("enemies", "approach_closest_player", player_coords)


func start_wave() -> void:
	window.close()
	_wave += 1
	_enemy_queue += 36


func _on_enemy_arena_area_body_exited(body: Node3D) -> void:
	var enemy: Enemy = body as Enemy
	if enemy:
		update_enemies.call_deferred()
