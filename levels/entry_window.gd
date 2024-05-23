class_name EntryWindow
extends Node3D

@export var state: STATE = STATE.CLOSED : set = _set_state

@onready var _open_pos: Vector3 = position + (4 * Vector3.FORWARD)
@onready var _closed_pos: Vector3 = position

enum STATE {CLOSED, OPEN}

var _tween: Tween


func _ready() -> void:
	Events.window_toggle_button_pressed.connect(_set_state)


func _open() -> void:
	if _tween: _tween.stop()
	_tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "position", _open_pos, 1)


func _close() -> void:
	if _tween: _tween.stop()
	_tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "position", _closed_pos, 1)


func _set_state(value: STATE) -> void:
	if not state == value: Events.window_state_changed.emit(value)
	state = value
	if not is_node_ready():
		await ready
	match state:
		STATE.OPEN: _open()
		STATE.CLOSED: _close()
