class_name Inventory
extends PanelContainer

const GUN = preload("res://guns/gun.tscn")
const GUN_THUMBNAIL = preload("res://guns/gun_thumbnail.tscn")

@onready var gun_inventory_container: GridContainer = %GunInventoryContainer
@onready var equipped_gun_thumbnail: GunThumbnail = %EquippedGunThumbnail


func _ready() -> void:
	for child in gun_inventory_container.get_children():
		gun_inventory_container.remove_child(child)
	
	equipped_gun_thumbnail.gun_stats = Global.data.gun_in_hand
	
	for gun_stats: GunStats in Global.data.guns_in_inventory:
		var gun_thumbnail: GunThumbnail = GUN_THUMBNAIL.instantiate()
		gun_thumbnail.gun_stats = gun_stats
		gun_inventory_container.add_child(gun_thumbnail)
