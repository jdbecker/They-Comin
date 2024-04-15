class_name Enemy
extends CharacterBody3D

signal destroyed

var SPEED := 3.0
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D as NavigationAgent3D


func _physics_process(delta: float) -> void:
	var current_location = global_transform.origin
	var next_location = navigation_agent_3d.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	velocity.x = new_velocity.x * SPEED
	velocity.z = new_velocity.z * SPEED
	
	# Add the gravity.
	if position.y > 1:
		velocity.y -= gravity * delta
	
	move_and_slide()


func approach_closest_player(players: Array) -> void:
	var closest_player = players.reduce(func(accum: Player, player: Player) -> Player: if distance_to(player) > distance_to(accum): return player else: return accum)
	if closest_player:
		navigation_agent_3d.target_position = closest_player.global_transform.origin


func distance_to(target: Node3D) -> float:
	return global_transform.origin.distance_to(target.global_transform.origin)


func shot() -> void:
	destroyed.emit()
	queue_free()
