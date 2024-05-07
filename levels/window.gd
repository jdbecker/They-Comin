class_name EntryWindow
extends Node3D

@export var state: STATE = STATE.OPEN

var is_busy: bool = false

enum STATE {OPEN, CLOSED}

var tween: Tween


func open() -> void:
	if state == STATE.OPEN: return
	var new_position := position
	new_position.z = -4
	if tween: tween.stop()
	tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", new_position, 1)
	state = STATE.OPEN


func close() -> void:
	if state == STATE.CLOSED: return
	var new_position := position
	new_position.z = 0
	if tween: tween.stop()
	tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", new_position, 1)
	state = STATE.CLOSED


func toggle() -> void:
	match state:
		STATE.OPEN: close()
		STATE.CLOSED: open()
