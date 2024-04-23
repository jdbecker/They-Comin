class_name EntryWindow
extends Node3D

@export var state: STATE = STATE.CLOSED

var is_busy: bool = false

enum STATE {BUSY, OPEN, CLOSED}


func open() -> void:
	if not state == STATE.CLOSED: return
	state = STATE.BUSY
	var new_position: Vector3 = position
	new_position.z -= 4
	var tween := get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", new_position, 4)
	await tween.finished
	print("done opening!")
	state = STATE.OPEN


func close() -> void:
	if not state == STATE.OPEN: return
	state = STATE.BUSY
	var new_position: Vector3 = position
	new_position.z += 4
	var tween := get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", new_position, 4)
	await tween.finished
	print("done closing!")
	state = STATE.CLOSED


func toggle() -> void:
	match state:
		STATE.OPEN: close()
		STATE.CLOSED: open()
