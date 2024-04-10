class_name Player
extends CharacterBody3D

@export var player_name: String = "Player Name"
@export var SPEED : float = 5.0
@export var SPRINT_MULTI : float = 3.0
@export_range(0.0, 1.0) var INERTIA : float = 0.2
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.5

@onready var camera: Camera3D = $Camera3D as Camera3D
@onready var label: Label3D = $Label3D as Label3D

const TILT_LOWER_LIMIT := deg_to_rad(-90.0)
const TILT_UPPER_LIMIT := deg_to_rad(90.0)


var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

	
func _ready() -> void:
	if not is_multiplayer_authority(): return

	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
	label.text = Global.data.player_name
	label.hide()
	
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
	
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
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
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		if Input.is_action_pressed("sprint"):
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


func respawn() -> void:
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0
	position.y = 3
	position.x = randf_range(-8, 8)
	position.z = randf_range(-8, 8)
