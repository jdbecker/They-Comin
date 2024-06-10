class_name EnergyUpgradesUI
extends Control

var _player_lazy: Player
var _player: Player : get = _get_player

@onready var run_speed_upgrade_button: EnergyUpgradeButton = %RunSpeedUpgradeButton as EnergyUpgradeButton
@onready var damage_upgrade_button: EnergyUpgradeButton = %DamageUpgradeButton as EnergyUpgradeButton
@onready var health_upgrade_button: EnergyUpgradeButton = %HealthUpgradeButton as EnergyUpgradeButton
@onready var drop_rate_upgrade_button: EnergyUpgradeButton = %DropRateUpgradeButton as EnergyUpgradeButton


func _ready() -> void:
	_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		Events.menu_closed.emit()
		queue_free()


func _redraw() -> void:
	run_speed_upgrade_button.cost = 30 * (1 + _player.run_speed_upgrade_level)
	damage_upgrade_button.cost = 30 * (1 + _player.damage_upgrade_level)
	health_upgrade_button.cost = 30 * (1 + _player.health_upgrade_level)
	drop_rate_upgrade_button.cost = 30 * (1 + _player.drop_rate_upgrade_level)
	
	run_speed_upgrade_button.disable = run_speed_upgrade_button.cost > _player.energy
	damage_upgrade_button.disable = damage_upgrade_button.cost > _player.energy
	health_upgrade_button.disable = health_upgrade_button.cost > _player.energy
	drop_rate_upgrade_button.disable = drop_rate_upgrade_button.cost > _player.energy
	
	run_speed_upgrade_button.description = "Increase player run speed multiplier by %s.\n(Currently %s)" % [_player.RUN_SPEED_LEVEL_INCREASE, _player.adjusted_run_speed_multi]
	damage_upgrade_button.description = "Increase player damage by %d%%.\n(Currently %d%%)" % [_player.DAMAGE_LEVEL_INCREASE * 100, _player.damage_multi * 100]
	health_upgrade_button.description = "(WORK IN PROGRESS)\nIncrease player health."
	drop_rate_upgrade_button.description = "Increase player new weapon drop rate by %d%%.\n(Currently %d%%)" % [_player.DROP_RATE_INCREASE * 100, roundi(_player.drop_rate * 100)]
	
	health_upgrade_button.disable = true # work in progress


func _get_player() -> Player:
	if not _player_lazy:
		var players: Array = get_tree().get_nodes_in_group("players") as Array
		_player_lazy = players.filter(func(player: Player) -> bool:
			return player.is_multiplayer_authority()
		).front()
	return _player_lazy


func _on_run_speed_upgrade_button_pressed() -> void:
	assert(_player.energy >= run_speed_upgrade_button.cost)
	_player.energy -= run_speed_upgrade_button.cost
	_player.run_speed_upgrade_level += 1
	_redraw()


func _on_damage_upgrade_button_pressed() -> void:
	assert(_player.energy >= damage_upgrade_button.cost)
	_player.energy -= damage_upgrade_button.cost
	_player.damage_upgrade_level += 1
	_redraw()


func _on_health_upgrade_button_pressed() -> void:
	assert(_player.energy >= health_upgrade_button.cost)
	_player.energy -= health_upgrade_button.cost
	_player.health_upgrade_level += 1
	_redraw()


func _on_drop_rate_upgrade_button_pressed() -> void:
	assert(_player.energy >= drop_rate_upgrade_button.cost)
	_player.energy -= drop_rate_upgrade_button.cost
	_player.drop_rate_upgrade_level += 1
	_redraw()
