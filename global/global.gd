extends Node

var data : Data : get = _get_data
var _data : Data


func _get_data() -> Data:
	
	if not _data:
		_data = Data.load_data()
	
	return _data
