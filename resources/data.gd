class_name Data
extends Resource

const FILE_LOCATION := "user://savedata.tres"

@export var player_name : String
@export var scrap : int = 0
@export var gun_in_hand : GunStats : get = _get_gun_in_hand
@export var guns_in_inventory : Array[GunStats] : get = _get_guns_in_inventory

static func load_data() -> Data:
	if FileAccess.file_exists(FILE_LOCATION):
		return ResourceLoader.load(FILE_LOCATION) as Data
	else:
		var data := Data.new()
		data.save_data()
		return data


func save_data() -> void:
	var err := ResourceSaver.save(self, FILE_LOCATION)
	assert(err == OK, "Failed to save!")


func _get_gun_in_hand() -> GunStats:
	
	if not gun_in_hand:
		gun_in_hand = GunStats.new()
	
	return gun_in_hand


func _get_guns_in_inventory() -> Array[GunStats]:
	
	if not guns_in_inventory:
		guns_in_inventory = []
	
	return guns_in_inventory
