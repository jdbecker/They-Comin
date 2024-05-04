class_name Tooltip
extends Control

@export var gun_stats: GunStats : set = _set_gun_stats

@onready var gun_stats_panel: GunStatsPanel = %GunStatsPanel as GunStatsPanel


func position_over_mouse() -> void:
	global_position = get_global_mouse_position()
	global_position.x = clamp(global_position.x, (gun_stats_panel.size.x / 2), get_viewport_rect().size.x - (gun_stats_panel.size.x / 2))
	if global_position.y - gun_stats_panel.size.y < 0:
		global_position.y = global_position.y + gun_stats_panel.size.y / 2 + 30
	else:
		global_position.y = global_position.y - gun_stats_panel.size.y / 2 - 10


func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		position_over_mouse()


func _set_gun_stats(value: GunStats) -> void:
	gun_stats = value
	
	if not is_node_ready():
		await ready
	
	gun_stats_panel.gun_stats = gun_stats
