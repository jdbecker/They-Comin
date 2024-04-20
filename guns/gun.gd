class_name Gun
extends Node3D

func trigger(_ray_cast_3d: RayCast3D) -> void:
	assert(false, "The abstract gun must be overridden!")
