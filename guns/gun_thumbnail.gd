class_name GunThumbnail
extends PanelContainer

@export var gun: Gun : set = _set_gun

const GUN = preload("res://guns/gun.tscn")

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport as SubViewport


func _set_gun(value: Gun) -> void:
	gun = value
	if not is_node_ready():
		await ready
	
	sub_viewport.add_child(gun)
