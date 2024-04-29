class_name Gun
extends Node

@export var stats: GunStats

@onready var pistol_rigid: RigidBody3D = $"Pistol-rigid" as RigidBody3D
@onready var pistol_animator: AnimationPlayer = $PistolAnimator as AnimationPlayer
@onready var gun_sound_player: AudioStreamPlayer3D = $GunSoundPlayer as AudioStreamPlayer3D


func trigger(ray_cast_3d: RayCast3D) -> void:
	if ray_cast_3d.is_colliding():
		var enemy: Enemy = ray_cast_3d.get_collider() as Enemy
		if enemy:
			enemy.shot.rpc_id(1)


@rpc("call_local")
func effects() -> void:
	match stats.type:
		GunStats.GunType.PISTOL:
			pistol_animator.speed_scale = stats.rate_of_fire
			pistol_animator.play("gun_fire")
			gun_sound_player.play()
		_:
			assert(false, "GunType %s not supported by gun effects!" % stats.type)


@rpc("call_local", "reliable")
func set_gun_stats(type: GunStats.GunType, hitscan: bool, damage: int, rate_of_fire: float) -> void:
	stats = GunStats.new()
	stats.type = type
	stats.hitscan = hitscan
	stats.damage = damage
	stats.rate_of_fire = rate_of_fire
	if not is_node_ready():
		await ready
	
	match stats.type:
		GunStats.GunType.PISTOL:
			pistol_rigid.show()
		_:
			assert(false, "GunType %s has no model yet!" % stats.type)
