class_name Inventory
extends PanelContainer

const GUN = preload("res://guns/gun.tscn")
const GUN_THUMBNAIL = preload("res://guns/gun_thumbnail.tscn")

@onready var gun_inventory_container: GridContainer = %GunInventoryContainer
@onready var equipped_gun_thumbnail: GunThumbnail = %EquippedGunThumbnail


func _ready() -> void:
	for child in gun_inventory_container.get_children():
		gun_inventory_container.remove_child(child)
	
	var equipped_gun: Gun = GUN.instantiate() as Gun
	equipped_gun.stats = Global.data.gun_in_hand
	equipped_gun_thumbnail.gun = equipped_gun
	
	for gun_stats: GunStats in Global.data.guns_in_inventory:
		var gun: Gun = GUN.instantiate() as Gun
		gun.stats = gun_stats
		var gun_thumbnail: GunThumbnail = GUN_THUMBNAIL.instantiate()
		gun_thumbnail.gun = gun
		gun_inventory_container.add_child(gun_thumbnail)
