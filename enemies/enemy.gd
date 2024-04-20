class_name Enemy
extends CharacterBody3D

signal destroyed(by: int)

var SPEED := 3.0
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D as NavigationAgent3D


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	var current_location := global_transform.origin
	var next_location := get_next_location()
	var new_velocity := (next_location - current_location).normalized()
	velocity.x = new_velocity.x * SPEED
	velocity.z = new_velocity.z * SPEED
	
	# Add the gravity.
	if position.y > 0:
		velocity.y -= gravity * delta
	
	if position.y < 0:
		position.y = lerp(position.y, 0.0, 0.5)
	
	move_and_slide()


func get_next_location() -> Vector3:
	return navigation_agent_3d.get_next_path_position()


func approach_closest_player(players: Array) -> void:
	if players.is_empty(): return
	var closest_player := players.reduce(
		func(accum: Player, player: Player) -> Player:
			if distance_to(player) < distance_to(accum): return player else: return accum
	) as Player
	if closest_player:
		navigation_agent_3d.target_position = closest_player.global_transform.origin


func distance_to(target: Node3D) -> float:
	return global_transform.origin.distance_to(target.global_transform.origin)


@rpc("any_peer", "call_local")
func shot() -> void:
	assert(is_multiplayer_authority())
	destroyed.emit(multiplayer.get_remote_sender_id())
	queue_free()
