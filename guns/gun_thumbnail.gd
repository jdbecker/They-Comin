class_name GunThumbnail
extends PanelContainer

@export var gun_stats: GunStats : set = _set_gun_stats

const GUN = preload("res://guns/gun.tscn")
const TOOLTIP = preload("res://ui/tooltip.tscn")
const SELECTED_GUN_DIALOGUE = preload("res://ui/selected_gun_dialogue.tscn")

var _tooltip: Tooltip
var _equipped: bool : get = _get_equipped

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport as SubViewport


func _set_gun_stats(value: GunStats) -> void:
	gun_stats = value
	
	if not is_node_ready():
		await ready
	
	var gun := GUN.instantiate() as Gun
	gun.stats = gun_stats
	sub_viewport.add_child(gun)


func _get_equipped() -> bool:
	return Global.data.gun_in_hand == gun_stats


func _on_area_2d_mouse_entered() -> void:
	_tooltip = TOOLTIP.instantiate()
	_tooltip.gun_stats = gun_stats
	Events.menu_closed.connect(_tooltip.queue_free)
	_tooltip.position_over_mouse.call_deferred()
	get_tree().root.add_child(_tooltip)


func _on_area_2d_mouse_exited() -> void:
	if is_instance_valid(_tooltip):
		_tooltip.queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_instance_valid(_tooltip):
		_tooltip.queue_free()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed and not _equipped:
			var selected_gun_dialogue: SelectedGunDialogue = SELECTED_GUN_DIALOGUE.instantiate()
			selected_gun_dialogue.selected_gun_stats = gun_stats
			_tooltip.queue_free()
			get_tree().root.add_child(selected_gun_dialogue)
