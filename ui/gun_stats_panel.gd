class_name GunStatsPanel
extends PanelContainer

@export var gun_stats: GunStats : set = _set_gun_stats

@onready var gun_type: Label = %GunType
@onready var damage: Label = %Damage
@onready var rate_of_fire: Label = %RateOfFire

var DEFAULT = Color(1, 1, 1)
var RED = Color(1, 0, 0)
var GREEN = Color(0, 1, 0)

func _set_gun_stats(value: GunStats) -> void:
	gun_stats = value
	
	if not is_node_ready():
		await ready
	
	gun_type.text = gun_stats.type_name()
	_set_stylized_gun_stat("damage", damage, gun_stats.damage, Global.data.gun_in_hand.damage)
	_set_stylized_gun_stat("rate", rate_of_fire, gun_stats.rate_of_fire, Global.data.gun_in_hand.rate_of_fire)

func _set_stylized_gun_stat(stat_type: String, element: Label, stat: float, in_hand: float) -> void:
	element.text = str(stat)
	if in_hand > stat:
		element.add_theme_color_override("font_color", RED)
	elif in_hand < stat:
		element.add_theme_color_override("font_color", GREEN)
	else:
		element.add_theme_color_override("font_color", DEFAULT)
	
	
