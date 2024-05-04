class_name GunStatsPanel
extends PanelContainer

@export var gun_stats: GunStats : set = _set_gun_stats

@onready var gun_type: Label = %GunType
@onready var damage: Label = %Damage
@onready var rate_of_fire: Label = %RateOfFire



func _set_gun_stats(value: GunStats) -> void:
	gun_stats = value
	
	if not is_node_ready():
		await ready
	
	gun_type.text = gun_stats.type_name()
	damage.text = str(gun_stats.damage)
	rate_of_fire.text = str(gun_stats.rate_of_fire)
