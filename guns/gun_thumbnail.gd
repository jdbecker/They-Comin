class_name GunThumbnail
extends PanelContainer

@export var gun_stats: GunStats : set = _set_gun_stats

const GUN = preload("res://guns/gun.tscn")

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport as SubViewport


func _set_gun_stats(value: GunStats) -> void:
	gun_stats = value
	
	if not is_node_ready():
		await ready
	
	var gun := GUN.instantiate() as Gun
	gun.stats = gun_stats
	sub_viewport.add_child(gun)
