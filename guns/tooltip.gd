class_name Tooltip
extends Control

@export var gun_stats: GunStats : set = _set_gun_stats

@onready var panel_container: PanelContainer = %PanelContainer as PanelContainer
@onready var gun_type: Label = %GunType as Label
@onready var damage: Label = %Damage as Label
@onready var rate_of_fire: Label = %RateOfFire as Label


func position_over_mouse() -> void:
	global_position = get_global_mouse_position()
	global_position.x = clamp(global_position.x, (panel_container.size.x / 2), get_viewport_rect().size.x - (panel_container.size.x / 2))
	if global_position.y - panel_container.size.y < 0:
		global_position.y = global_position.y + panel_container.size.y / 2 + 30
	else:
		global_position.y = global_position.y - panel_container.size.y / 2 - 10


func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		position_over_mouse()


func _set_gun_stats(value: GunStats) -> void:
	gun_stats = value
	
	if not is_node_ready():
		await ready
	
	gun_type.text = gun_stats.type_name()
	damage.text = str(gun_stats.damage)
	rate_of_fire.text = str(gun_stats.rate_of_fire)
