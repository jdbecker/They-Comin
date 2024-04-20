extends Node

var data : Data : get = _get_data
var _data : Data


func _get_data() -> Data:
	
	if not _data:
		_data = Data.load_data()
	
	return _data


@rpc("call_local", "any_peer")
func shoot_enemy(enemy_name: String) -> void:
	var enemy := get_tree().get_nodes_in_group("enemies").filter(func(this: Enemy) -> bool: return this.name == enemy_name).front() as Enemy
	if enemy:
		enemy.shot()
