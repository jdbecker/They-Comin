class_name Inventory
extends PanelContainer

const GUN_THUMBNAIL = preload("res://guns/gun_thumbnail.tscn")

@onready var gun_inventory_container: GridContainer = %GunInventoryContainer
@onready var equipped_gun_thumbnail: GunThumbnail = %EquippedGunThumbnail


func _ready() -> void:
	Events.inventory_changed.connect(redraw_inventory)
	Events.equipped_gun_changed.connect(redraw_inventory)
	redraw_inventory()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		Events.menu_closed.emit()
		queue_free()


func redraw_inventory() -> void:
	for child in gun_inventory_container.get_children():
		gun_inventory_container.remove_child(child)
	
	equipped_gun_thumbnail.gun_stats = Global.data.gun_in_hand
	
	for gun_stats: GunStats in Global.data.guns_in_inventory:
		var gun_thumbnail: GunThumbnail = GUN_THUMBNAIL.instantiate()
		gun_thumbnail.gun_stats = gun_stats
		gun_inventory_container.add_child(gun_thumbnail)
