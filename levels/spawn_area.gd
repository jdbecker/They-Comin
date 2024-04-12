class_name SpawnArea
extends Area3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func get_random_position() -> Vector3:
	var centerpos := collision_shape_3d.global_position
	var shape: BoxShape3D = collision_shape_3d.shape as BoxShape3D
	var posx := (randf_range(centerpos.x - shape.size.x/2.0, centerpos.x + shape.size.x/2.0))
	var posz := (randf_range(centerpos.z - shape.size.z/2.0, centerpos.x + shape.size.z/2.0))
	var posy := centerpos.y
	return Vector3(posx, posy, posz)
	
