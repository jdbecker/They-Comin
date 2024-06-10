class_name EnergyUpgradeButton
extends Button

const DEFAULT := Color(1, 1, 1)
const RED := Color(1, 0, 0)

@export var cost: int : set = _set_cost
@export_multiline var description: String : set = _set_description
@export var disable: bool : set = _set_is_disabled

@onready var _cost_label: Label = %Cost
@onready var _description_label: Label = %Description


func _set_cost(value: int) -> void:
	cost = value
	
	if not is_node_ready():
		await ready
	
	_cost_label.text = str(cost)


func _set_description(value: String) -> void:
	description = value
	
	if not is_node_ready():
		await ready
	
	_description_label.text = description


func _set_is_disabled(value: bool) -> void:
	disable = value
	disabled = disable
	
	if not is_node_ready():
		await ready
	
	if disable:
		_cost_label.add_theme_color_override("font_color", RED)
		_description_label.add_theme_color_override("font_color", RED)
	else:
		_cost_label.add_theme_color_override("font_color", DEFAULT)
		_description_label.add_theme_color_override("font_color", DEFAULT)
