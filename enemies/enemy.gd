class_name Enemy
extends CharacterBody3D

signal destroyed

var SPEED := 3.0
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D as NavigationAgent3D


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	var current_location := global_transform.origin
	var next_location := navigation_agent_3d.get_next_path_position()
	var new_velocity := (next_location - current_location).normalized()
	velocity.x = new_velocity.x * SPEED
	velocity.z = new_velocity.z * SPEED
	
	# Add the gravity.
	if position.y > 0:
		velocity.y -= gravity * delta
	
	if position.y < 0:
		position.y = lerp(position.y, 0.0, 0.5)
	
	move_and_slide()


func approach_closest_player(players: Array) -> void:
	var closest_player := players.reduce(
		func(accum: Player, player: Player) -> Player:
			if distance_to(player) < distance_to(accum): return player else: return accum
	) as Player
	if closest_player:
		navigation_agent_3d.target_position = closest_player.global_transform.origin


func distance_to(target: Node3D) -> float:
	return global_transform.origin.distance_to(target.global_transform.origin)


@rpc("call_local", "any_peer")
func shot() -> void:
	if not is_multiplayer_authority(): return
	destroyed.emit()
	queue_free()
