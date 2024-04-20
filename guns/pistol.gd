extends Gun

@onready var ray_cast_3d: RayCast3D = $RayCast3D


func trigger() -> void:
	if ray_cast_3d.is_colliding():
		print("enemy hit!")
		var enemy: Enemy = ray_cast_3d.get_collider() as Enemy
		
		enemy.shot.rpc_id(1)
		#Global.shoot_enemy.rpc_id(1, enemy.name)
	else:
		print("missed!")
