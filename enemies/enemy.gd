class_name Enemy
extends CharacterBody3D

signal destroyed(by: int)

@export var logging: bool = false
@export var max_hp: int = 2 : set = _set_max_hp
@export var current_hp: int = max_hp : set = _setcurrent_hp
@export var speed := 5.0
@export var hover_height := 0

var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D as NavigationAgent3D
@onready var enemy_hp_bar: ProgressBar = %EnemyHpBar
@onready var death_sound_player: AudioStreamPlayer3D = $DeathSoundPlayer


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return

	add_gravity(delta)
	add_hover()

	if not navigation_agent_3d.is_navigation_finished():
		apply_velocity()
	
	if logging:
		print("velocity.y = %s" % velocity.y)
	
	default_behavior()


func get_current_location() -> Vector3:
	return global_transform.origin


func get_next_location() -> Vector3:
	return navigation_agent_3d.get_next_path_position()


func get_direction() -> Vector3:
	return (get_next_location() - get_current_location()).normalized()


func apply_velocity() -> void:
	var direction := get_direction()
	velocity.z = direction.z * speed
	velocity.x = direction.x * speed


func add_gravity(delta: float) -> void:
	# Add the gravity.
	if position.y > hover_height:
		velocity.y -= gravity * delta


func add_hover() -> void:
	#Add hover
	if position.y < hover_height:
		velocity.y = -position.y


func default_behavior() -> void:
	move_and_slide()


func approach_closest_player(player_coords: Array) -> void:
	if player_coords.is_empty(): return
	var closest_target := player_coords.reduce(
		func(accum: Vector3, target: Vector3) -> Vector3:
			if distance_to(target) < distance_to(accum): return target else: return accum
	) as Vector3
	if closest_target:
		navigation_agent_3d.target_position = closest_target


func distance_to(target: Vector3) -> float:
	return global_transform.origin.distance_to(target)


@rpc("any_peer", "call_local")
func shot() -> void:
	current_hp -= 1
	if current_hp <= 0:
		destroyed.emit(multiplayer.get_remote_sender_id())
		destroy.rpc()


@rpc("call_local")
func destroy() -> void:
	remove_from_group("enemies")
	speed = 0
	hover_height = -1
	collision_layer = 3
	enemy_hp_bar.hide()
	death_sound_player.play()
	await get_tree().create_timer(1).timeout
	queue_free()


func _set_max_hp(value: int) -> void:
	if not is_node_ready():
		await ready
	max_hp = value
	current_hp = max_hp
	enemy_hp_bar.max_value = max_hp
	enemy_hp_bar.value = max_hp


func _setcurrent_hp(value: int) -> void:
	if not is_node_ready():
		await ready
	current_hp = value
	enemy_hp_bar.value = current_hp
