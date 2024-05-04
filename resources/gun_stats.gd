class_name GunStats
extends Resource

enum GunType { PISTOL }

@export var type: GunType = GunType.PISTOL
@export var hitscan: bool = true
@export var damage: int = 1
@export var rate_of_fire: float = 1.0


static func random_gun(level: int) -> GunStats:
	var new_stats := GunStats.new()
	new_stats.rate_of_fire = snapped(randf_range(0.5, 2.0), 0.01)
	new_stats.damage = randi_range(1, level)
	return new_stats


func type_name() -> String:
	return GunType.keys()[type]


func _to_string() -> String:
	return "{type: %s, hitscan: %s, damage: %s, rate_of_fire: %s}" % [type, hitscan, damage, rate_of_fire]
