class_name DebugPanel
extends Control

@onready var window_opened_button: CheckButton = %WindowOpenedButton


func _ready() -> void:
	Events.window_state_changed.connect(_on_window_state_changed)


func _on_window_state_changed(state: EntryWindow.STATE) -> void:
	window_opened_button.button_pressed = state == EntryWindow.STATE.OPEN


func _on_window_opened_button_toggled(toggled_on: bool) -> void:
	Events.window_toggle_button_pressed.emit(toggled_on)
