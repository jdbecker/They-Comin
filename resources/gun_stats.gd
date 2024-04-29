class_name GunStats
extends Resource

enum GunType { PISTOL }

@export var type: GunType = GunType.PISTOL
@export var hitscan: bool = true
@export var damage: int = 1
@export var rate_of_fire: float = 1.0


func _to_string() -> String:
	return "{type: %s, hitscan: %s, damage: %s, rate_of_fire: %s}" % [type, hitscan, damage, rate_of_fire]
