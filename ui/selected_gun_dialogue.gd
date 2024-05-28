class_name SelectedGunDialogue
extends Panel

@export var selected_gun_stats: GunStats : set = _set_gun_stats

@onready var equipped_gun_stats_panel: GunStatsPanel = %EquippedGunStatsPanel as GunStatsPanel
@onready var selected_gun_stats_panel: GunStatsPanel = %SelectedGunStatsPanel as GunStatsPanel


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		queue_free()


func _set_gun_stats(value: GunStats) -> void:
	selected_gun_stats = value
	
	if not is_node_ready():
		await ready
	
	equipped_gun_stats_panel.gun_stats = Global.data.gun_in_hand
	selected_gun_stats_panel.gun_stats = selected_gun_stats


func _on_cancel_button_pressed() -> void:
	queue_free()


func _on_scrap_button_pressed() -> void:
	Global.data.guns_in_inventory.erase(selected_gun_stats)
	Events.inventory_changed.emit()
	Global.data.save_data()
	queue_free()


func _on_equip_button_pressed() -> void:
	Global.data.guns_in_inventory.append(Global.data.gun_in_hand)
	Global.data.gun_in_hand = selected_gun_stats
	Global.data.guns_in_inventory.erase(selected_gun_stats)
	Events.equipped_gun_changed.emit()
	Global.data.save_data()
	queue_free()
