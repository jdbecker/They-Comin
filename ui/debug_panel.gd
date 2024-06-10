class_name DebugPanel
extends Control

var _player_lazy: Player
var _player: Player : get = _get_player

@onready var window_opened_button: CheckButton = %WindowOpenedButton


func _ready() -> void:
	Events.window_state_changed.connect(_on_window_state_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit") or event.is_action_pressed("console"):
		Events.menu_closed.emit()
		queue_free()


func _get_player() -> Player:
	if not _player_lazy:
		var players: Array = get_tree().get_nodes_in_group("players") as Array
		_player_lazy = players.filter(func(player: Player) -> bool:
			return player.is_multiplayer_authority()
		).front()
	return _player_lazy


func _on_window_state_changed(state: EntryWindow.STATE) -> void:
	window_opened_button.button_pressed = state == EntryWindow.STATE.OPEN


func _on_window_opened_button_toggled(toggled_on: bool) -> void:
	Events.window_toggle_button_pressed.emit(toggled_on)


func _on_add_energy_button_pressed() -> void:
	_player.energy += 30
