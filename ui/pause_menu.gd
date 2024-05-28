class_name PauseMenu
extends Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		_close()


func _close() -> void:
	Events.menu_closed.emit()
	queue_free()


func _on_resume_button_pressed() -> void:
	_close()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

