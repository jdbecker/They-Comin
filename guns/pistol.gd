extends Gun


func trigger(ray_cast_3d: RayCast3D) -> void:
	if ray_cast_3d.is_colliding():
		var enemy: Enemy = ray_cast_3d.get_collider() as Enemy
		if enemy:
			enemy.shot.rpc_id(1)
