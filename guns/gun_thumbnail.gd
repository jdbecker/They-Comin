class_name GunThumbnail
extends PanelContainer

@export var gun_stats: GunStats : set = _set_gun_stats

const GUN = preload("res://guns/gun.tscn")
const TOOLTIP = preload("res://guns/tooltip.tscn")

var _tooltip: Tooltip

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport as SubViewport


func _set_gun_stats(value: GunStats) -> void:
	gun_stats = value
	
	if not is_node_ready():
		await ready
	
	var gun := GUN.instantiate() as Gun
	gun.stats = gun_stats
	sub_viewport.add_child(gun)


func _on_area_2d_mouse_entered() -> void:
	_tooltip = TOOLTIP.instantiate()
	_tooltip.gun_stats = gun_stats
	_tooltip.position_over_mouse.call_deferred()
	get_tree().root.add_child(_tooltip)


func _on_area_2d_mouse_exited() -> void:
	_tooltip.queue_free()
