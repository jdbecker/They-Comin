class_name Player
extends CharacterBody3D

enum STATE {ACTIVE, IN_MENU}

const TILT_LOWER_LIMIT := deg_to_rad(-90.0)
const TILT_UPPER_LIMIT := deg_to_rad(90.0)
const INVENTORY = preload("res://ui/Inventory.tscn")
const DEBUG_PANEL = preload("res://ui/debug_panel.tscn")
const PAUSE_MENU = preload("res://ui/pause_menu.tscn")

@export var SPEED : float = 5.0
@export var SPRINT_MULTI : float = 2.0
@export_range(0.0, 1.0) var INERTIA : float = 0.2
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.4

var _state: STATE = STATE.ACTIVE : set = _set_state
var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _tween: Tween

@onready var enemy_overlap: Area3D = $EnemyOverlap
@onready var camera: Camera3D = $Camera3D as Camera3D
@onready var label: Label3D = $Label3D as Label3D
@onready var reach_raycast: RayCast3D = $Camera3D/ReachRayCast3D as RayCast3D
@onready var shoot_raycast: RayCast3D = $Camera3D/ShootRayCast3D as RayCast3D
@onready var hand_slot: Node3D = $Camera3D/HandSlot as Node3D
@onready var ui: Control = $Camera3D/UI as Control
@onready var message: Label = %Message as Label
@onready var enemies_count: Label = %EnemiesCount as Label
@onready var kill_count_label: Label = %KillCount as Label
@onready var gun: Gun = $Camera3D/HandSlot/Gun
@onready var menu: Control = %Menu


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float

var kill_count: int = 0: set = _set_kill_count


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	ui.hide()
	
	if not is_multiplayer_authority():
		ready.connect(func() -> void: broadcast_gun_stats.rpc_id(name.to_int()))
		return
	
	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	message.modulate = Color(1, 1, 1, 0)
	ui.show()
	
	Events.menu_closed.connect(activate)
	
	label.text = Global.data.player_name
	label.hide()
	
	broadcast_gun_stats()
	Events.equipped_gun_changed.connect(broadcast_gun_stats)
	
	respawn()


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if _mouse_input:
		var mouse_motion := event as InputEventMouseMotion
		_rotation_input = -mouse_motion.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -mouse_motion.relative.y * MOUSE_SENSITIVITY


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	match _state:
		STATE.ACTIVE:
			if event.is_action_pressed("exit"):
				_open_pause_menu()
			if event.is_action_pressed("console") and Global.data.player_name == "json" and name == "1":
				_open_debug()
			if event.is_action_pressed("interact"):
				_interact()
			if event.is_action_pressed("trigger"):
				_trigger()
		STATE.IN_MENU:
			pass
		_:
			assert(false, "Unhandled state in _input: %s" % STATE.find_key(_state))


func _update_camera(delta: float) -> void:
	
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	camera.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	camera.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Update camera movement based on mouse movement
	_update_camera(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and _state == STATE.ACTIVE:
		velocity.y = JUMP_VELOCITY
	
	# Check if stuck intersecting with something else
	if get_slide_collision_count() > 0:
		_unstuck()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and _state == STATE.ACTIVE:
		if Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward") and is_on_floor():
			velocity.x = lerp(velocity.x, direction.x * SPEED * SPRINT_MULTI, INERTIA)
			velocity.z = lerp(velocity.z, direction.z * SPEED * SPRINT_MULTI, INERTIA)
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, INERTIA)
			velocity.z = lerp(velocity.z, direction.z * SPEED, INERTIA)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if position.y <= -30:
		respawn()

	move_and_slide()


func activate() -> void:
	_state = STATE.ACTIVE


func _set_state(value: STATE) -> void:
	_state = value
	
	match _state:
		STATE.ACTIVE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		STATE.IN_MENU:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_:
			assert(false, "Unhandled state in _set_state: %s" % STATE.find_key(_state))


func _unstuck() -> void:
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		if collision.get_collider() is Player or collision.get_collider() is EntryWindow:
			var shunt_vector: Vector3 = collision.get_normal() * .01
			position = position + shunt_vector


func _set_kill_count(value: int) -> void:
	kill_count = value
	kill_count_label.text = str(value)


@rpc("any_peer", "reliable")
func broadcast_gun_stats() -> void:
	if not is_node_ready():
		await ready
	assert(Global.data.gun_in_hand, "Gun in hand is missing!")
	var stats := Global.data.gun_in_hand
	gun.set_gun_stats.rpc(stats.type, stats.hitscan, stats.damage, stats.rate_of_fire)


func respawn() -> void:
	kill_count = 0
	velocity = Vector3.ZERO
	_mouse_rotation = Vector3.ZERO
	var empty_spawn_areas: Array = get_tree().get_nodes_in_group("player_spawn").filter(func(area: SpawnArea) -> bool: return not area.has_overlapping_bodies()) as Array
	if empty_spawn_areas.is_empty():
		empty_spawn_areas = get_tree().get_nodes_in_group("player_spawn") as Array
	empty_spawn_areas.shuffle()
	var spawn_area: SpawnArea = empty_spawn_areas.front() as SpawnArea
	position = spawn_area.collision_shape_3d.global_position


@rpc("call_local", "any_peer")
func display_message(message_text: String) -> void:
	message.text = message_text
	if _tween:
		_tween.stop()
	_tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	_tween.set_parallel(false)
	_tween.tween_property(message, "modulate", Color(1, 1, 1, 1), .5)
	_tween.tween_property(message, "modulate", Color(1, 1, 1, 1), 2)
	_tween.tween_property(message, "modulate", Color(1, 1, 1, 0), 1)


@rpc("call_local", "any_peer", "reliable")
func add_kill() -> void:
	kill_count += 1


@rpc("any_peer", "call_local", "reliable")
func get_gun(level: int) -> void:
	Global.data.guns_in_inventory.append(GunStats.random_gun(level))
	Global.data.save_data()


func update_enemies_count(count: int) -> void:
	enemies_count.text = str(count)


func _interact() -> void:
	pass
	#var object := reach_raycast.get_collider() as Node
	#if object and object.is_in_group("guns"):
		#var gun := object.duplicate() as RigidBody3D
		#gun.freeze = true
		#gun.transform = Transform3D.IDENTITY
		#hand_slot.add_child(gun)


func _trigger() -> void:
	assert(gun, "Nothing in hand to trigger!")
	if not gun.pistol_animator.is_playing():
		gun.effects.rpc()
		gun.trigger(shoot_raycast)


func _open_pause_menu() -> void:
	_open_menu(PAUSE_MENU)


func _open_inventory() -> void:
	_open_menu(INVENTORY)


func _open_debug() -> void:
	_open_menu(DEBUG_PANEL)


func _open_menu(menu_scene: PackedScene) -> void:
	if not is_multiplayer_authority(): return
	
	assert(_state != STATE.IN_MENU)
	assert(menu.get_child_count() == 0)
	
	_state = STATE.IN_MENU
	
	var new_menu := menu_scene.instantiate()
	menu.add_child.call_deferred(new_menu)


func _on_enemy_overlap_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		var enemy := body as Enemy
		if enemy:
			display_message("They got you!\n You had %s kills." % kill_count)
			respawn()

